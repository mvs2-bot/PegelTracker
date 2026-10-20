-- PegelTracker: Datenbank-Schema im Core-Projekt (gemeinsam mit TravelBase, Questlog, Dashboard)
-- Einmalig im Supabase-Dashboard unter "SQL Editor" ausführen (oder als Migration "pegeltracker_core").
-- Baut auf der Migration overall_core auf (overall_profiles, overall_apps, overall_app_access,
-- overall_has_app_role, overall_user_app_role). Kann mehrfach ausgeführt werden.
--
-- Tabellen
--   pegel_drinks         jedes erfasste Getränk (Zeitpunkt, Menge, Vol.-%, Koffein, Essensgrundlage)
--   pegel_custom_drinks  eigene Getränke für das Dropdown (z. B. Lieblingscocktail, Mate)
--
-- Trinksessions werden NICHT gespeichert, sondern in der App aus den Getränken berechnet:
-- eine Session läuft vom ersten Getränk, bis laut Berechnung 0,0 ‰ erreicht sind.
-- So bleiben sie richtig, wenn sich Gewicht oder Formel ändern oder ein Getränk nachgetragen wird.
--
-- Wer was darf (Zugang über overall_app_access, App "pegeltracker")
--   member  sieht und bearbeitet nur die eigenen Getränke
--   admin   (App-Admin oder globaler Admin) sieht zusätzlich die Getränke aller Mitglieder,
--           ändern kann auch der Admin nur die eigenen
--   ohne Zugang  sieht nichts
--
-- Danach: Ines im Dashboard unter Admin-Einstellungen → PegelTracker als "Mitglied" freischalten.

-- ───────── App registrieren ─────────
insert into public.overall_apps (id, name, url, is_active)
values ('pegeltracker', 'PegelTracker', 'https://mvs2-bot.github.io/PegelTracker/', true)
on conflict (id) do nothing;

-- ───────── Rollen-Helfer ─────────
create or replace function public.pegel_is_member()
returns boolean language sql stable security definer set search_path = '' as $$
    select public.overall_has_app_role('pegeltracker', 'member');
$$;

create or replace function public.pegel_is_admin()
returns boolean language sql stable security definer set search_path = '' as $$
    select public.overall_has_app_role('pegeltracker', 'admin');
$$;

-- ───────── Getränke ─────────
create table if not exists public.pegel_drinks (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
    consumed_at  timestamptz not null default now(),
    name         text not null check (char_length(name) between 1 and 80),
    category     text not null default 'other'
                 check (category in ('beer', 'wine', 'sparkling', 'cocktail', 'shot', 'spirit', 'caffeine', 'other')),
    volume_ml    numeric(7, 1) not null check (volume_ml > 0 and volume_ml <= 5000),
    abv          numeric(4, 1) not null default 0 check (abv >= 0 and abv <= 100),
    caffeine_mg  numeric(6, 1) not null default 0 check (caffeine_mg >= 0 and caffeine_mg <= 2000),
    with_food    boolean not null default false,
    note         text check (note is null or char_length(note) <= 500),
    created_at   timestamptz not null default now()
);
create index if not exists pegel_drinks_user_time on public.pegel_drinks (user_id, consumed_at);

-- ───────── Eigene Getränke ─────────
create table if not exists public.pegel_custom_drinks (
    id           uuid primary key default gen_random_uuid(),
    user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
    name         text not null check (char_length(name) between 1 and 80),
    category     text not null default 'other'
                 check (category in ('beer', 'wine', 'sparkling', 'cocktail', 'shot', 'spirit', 'caffeine', 'other')),
    volume_ml    numeric(7, 1) not null check (volume_ml > 0 and volume_ml <= 5000),
    abv          numeric(4, 1) not null default 0 check (abv >= 0 and abv <= 100),
    caffeine_mg  numeric(6, 1) not null default 0 check (caffeine_mg >= 0 and caffeine_mg <= 2000),
    created_at   timestamptz not null default now(),
    unique (user_id, name)
);

-- ───────── Zugriffsregeln ─────────
alter table public.pegel_drinks enable row level security;
alter table public.pegel_custom_drinks enable row level security;

revoke all on public.pegel_drinks, public.pegel_custom_drinks from anon;
grant select, insert, update, delete on public.pegel_drinks, public.pegel_custom_drinks to authenticated;

drop policy if exists pegel_drinks_select on public.pegel_drinks;
create policy pegel_drinks_select on public.pegel_drinks for select to authenticated
    using (((user_id = (select auth.uid())) and (select public.pegel_is_member())) or (select public.pegel_is_admin()));

drop policy if exists pegel_drinks_insert on public.pegel_drinks;
create policy pegel_drinks_insert on public.pegel_drinks for insert to authenticated
    with check ((user_id = (select auth.uid())) and (select public.pegel_is_member()));

drop policy if exists pegel_drinks_update on public.pegel_drinks;
create policy pegel_drinks_update on public.pegel_drinks for update to authenticated
    using ((user_id = (select auth.uid())) and (select public.pegel_is_member()))
    with check ((user_id = (select auth.uid())) and (select public.pegel_is_member()));

drop policy if exists pegel_drinks_delete on public.pegel_drinks;
create policy pegel_drinks_delete on public.pegel_drinks for delete to authenticated
    using ((user_id = (select auth.uid())) and (select public.pegel_is_member()));

drop policy if exists pegel_custom_drinks_all on public.pegel_custom_drinks;
create policy pegel_custom_drinks_all on public.pegel_custom_drinks for all to authenticated
    using ((user_id = (select auth.uid())) and (select public.pegel_is_member()))
    with check ((user_id = (select auth.uid())) and (select public.pegel_is_member()));

-- ───────── Personen + Profildaten für die Berechnung ─────────
-- Mitglied: nur sich selbst. Admin: sich selbst und alle mit Zugang zum PegelTracker.
-- overall_profiles selbst bleibt unverändert (dort sieht nur der globale Admin fremde Profile).
create or replace function public.pegel_people()
returns table (id uuid, display_name text, gender text, height_cm smallint, weight_kg numeric, birthday date, app_role text, is_me boolean)
language sql stable security definer set search_path = '' as $$
    select p.id, p.display_name, p.gender, p.height_cm, p.weight_kg, p.birthday,
           public.overall_user_app_role(p.id, 'pegeltracker') as app_role,
           p.id = (select auth.uid()) as is_me
    from public.overall_profiles p
    where public.overall_user_app_role(p.id, 'pegeltracker') is not null
      and public.overall_role_rank(public.overall_user_app_role(p.id, 'pegeltracker')) >= public.overall_role_rank('member')
      and (p.id = (select auth.uid()) or public.pegel_is_admin())
      and public.pegel_is_member()
    order by (p.id = (select auth.uid())) desc, p.display_name;
$$;

revoke execute on function public.pegel_is_member(), public.pegel_is_admin(), public.pegel_people() from public, anon;
grant execute on function public.pegel_is_member(), public.pegel_is_admin(), public.pegel_people() to authenticated;
