-- Flovi relocation workflow — schema
-- Run this once in the Supabase SQL Editor for a fresh project.
-- Single source of truth for the data model shared by both apps
-- (see packages/shared/model.md for the plain-language spec).

create extension if not exists "pgcrypto";

create type relocation_status as enum ('pending', 'booked', 'completed', 'cancelled');

create table if not exists relocation_requests (
  id uuid primary key default gen_random_uuid(),
  origin text not null,
  destination text not null,
  scheduled_date date not null,
  notes text,
  status relocation_status not null default 'pending',
  created_by uuid not null references auth.users(id) default auth.uid(),
  booked_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- keep updated_at current on every row change
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists relocation_requests_set_updated_at on relocation_requests;
create trigger relocation_requests_set_updated_at
  before update on relocation_requests
  for each row execute function set_updated_at();

-- Row Level Security
-- Deliberately simple for this challenge's scope: no dispatcher/driver role table exists,
-- so any authenticated user can read all requests and update any request (needed for a driver
-- to book a gig they didn't create). See README.md / docs/reflection.md for the tradeoff.
alter table relocation_requests enable row level security;

drop policy if exists "authenticated users can read all requests" on relocation_requests;
create policy "authenticated users can read all requests"
  on relocation_requests for select
  to authenticated
  using (true);

drop policy if exists "authenticated users can create requests" on relocation_requests;
create policy "authenticated users can create requests"
  on relocation_requests for insert
  to authenticated
  with check (created_by = auth.uid());

drop policy if exists "authenticated users can update requests" on relocation_requests;
create policy "authenticated users can update requests"
  on relocation_requests for update
  to authenticated
  using (true)
  with check (true);

-- Realtime: publish changes so both apps can subscribe to postgres_changes
alter publication supabase_realtime add table relocation_requests;
