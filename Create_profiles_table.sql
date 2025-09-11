-- Setup the Users Auth
select * from auth.users;

-- Create profiles table
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  full_name text,
  avatar_url text,
  website text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security
alter table public.profiles enable row level security;

-- Policy: Allow users to select their own profile
create policy "Individuals can view their own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

-- Policy: Allow users to update their own profile
create policy "Individuals can update their own profile"
  on public.profiles
  for update
  using (auth.uid() = id);

-- Optional: allow insert only for the authenticated user on their own row
create policy "Individuals can insert their own profile"
  on public.profiles
  for insert
  with check (auth.uid() = id);
