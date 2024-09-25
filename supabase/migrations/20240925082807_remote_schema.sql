create type "public"."app_permission" as enum ('events.crud', 'games.crud', 'gameservers.crud', 'links.crud', 'profiles.crud', 'users.crud');

create type "public"."app_role" as enum ('admin', 'moderator');

create type "public"."link_type" as enum ('irc', 'teamspeak', 'discord', 'website', 'steam');

create type "public"."region" as enum ('eu', 'na', 'all');

create table "public"."events" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "modified_at" timestamp with time zone default now(),
    "modified_by" uuid,
    "title" text not null default ''::text,
    "description" text not null default ''::text,
    "note" text,
    "markdown" text,
    "date" date not null,
    "location" text,
    "link" text
);


alter table "public"."events" enable row level security;

create table "public"."games" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "steam_id" bigint,
    "name" text,
    "shorthand" text,
    "created_by" uuid
);


alter table "public"."games" enable row level security;

create table "public"."gameservers" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "modified_at" timestamp with time zone,
    "created_by" uuid,
    "modified_by" uuid,
    "address" text,
    "port" text,
    "game" bigint,
    "description" text,
    "region" region
);


alter table "public"."gameservers" enable row level security;

create table "public"."links" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid,
    "url" text,
    "title" text,
    "type" link_type,
    "region" region
);


alter table "public"."links" enable row level security;

create table "public"."profiles" (
    "id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "modified_at" timestamp with time zone default now(),
    "title" text,
    "subtitle" text,
    "markdown" text,
    "modified_by" uuid,
    "nickname" text
);


alter table "public"."profiles" enable row level security;

create table "public"."role_permissions" (
    "id" bigint generated by default as identity not null,
    "role" app_role not null,
    "permission" app_permission not null
);


create table "public"."user_roles" (
    "id" bigint generated by default as identity not null,
    "user_id" uuid not null,
    "role" app_role not null
);


CREATE UNIQUE INDEX events_pkey ON public.events USING btree (id);

CREATE UNIQUE INDEX games_pkey ON public.games USING btree (id);

CREATE UNIQUE INDEX gameservers_pkey ON public.gameservers USING btree (id);

CREATE UNIQUE INDEX links_pkey ON public.links USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX role_permissions_pkey ON public.role_permissions USING btree (id);

CREATE UNIQUE INDEX role_permissions_role_permission_key ON public.role_permissions USING btree (role, permission);

CREATE UNIQUE INDEX user_roles_pkey ON public.user_roles USING btree (id);

CREATE UNIQUE INDEX user_roles_user_id_role_key ON public.user_roles USING btree (user_id, role);

alter table "public"."events" add constraint "events_pkey" PRIMARY KEY using index "events_pkey";

alter table "public"."games" add constraint "games_pkey" PRIMARY KEY using index "games_pkey";

alter table "public"."gameservers" add constraint "gameservers_pkey" PRIMARY KEY using index "gameservers_pkey";

alter table "public"."links" add constraint "links_pkey" PRIMARY KEY using index "links_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."role_permissions" add constraint "role_permissions_pkey" PRIMARY KEY using index "role_permissions_pkey";

alter table "public"."user_roles" add constraint "user_roles_pkey" PRIMARY KEY using index "user_roles_pkey";

alter table "public"."events" add constraint "events_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."events" validate constraint "events_created_by_fkey";

alter table "public"."events" add constraint "events_modified_by_fkey" FOREIGN KEY (modified_by) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."events" validate constraint "events_modified_by_fkey";

alter table "public"."games" add constraint "games_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."games" validate constraint "games_created_by_fkey";

alter table "public"."gameservers" add constraint "gameservers_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."gameservers" validate constraint "gameservers_created_by_fkey";

alter table "public"."gameservers" add constraint "gameservers_game_fkey" FOREIGN KEY (game) REFERENCES games(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."gameservers" validate constraint "gameservers_game_fkey";

alter table "public"."gameservers" add constraint "gameservers_modified_by_fkey" FOREIGN KEY (modified_by) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."gameservers" validate constraint "gameservers_modified_by_fkey";

alter table "public"."links" add constraint "links_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."links" validate constraint "links_created_by_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_modified_by_fkey" FOREIGN KEY (modified_by) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE SET NULL not valid;

alter table "public"."profiles" validate constraint "profiles_modified_by_fkey";

alter table "public"."role_permissions" add constraint "role_permissions_role_permission_key" UNIQUE using index "role_permissions_role_permission_key";

alter table "public"."user_roles" add constraint "user_roles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."user_roles" validate constraint "user_roles_user_id_fkey";

alter table "public"."user_roles" add constraint "user_roles_user_id_role_key" UNIQUE using index "user_roles_user_id_role_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$function$
;

grant delete on table "public"."events" to "anon";

grant insert on table "public"."events" to "anon";

grant references on table "public"."events" to "anon";

grant select on table "public"."events" to "anon";

grant trigger on table "public"."events" to "anon";

grant truncate on table "public"."events" to "anon";

grant update on table "public"."events" to "anon";

grant delete on table "public"."events" to "authenticated";

grant insert on table "public"."events" to "authenticated";

grant references on table "public"."events" to "authenticated";

grant select on table "public"."events" to "authenticated";

grant trigger on table "public"."events" to "authenticated";

grant truncate on table "public"."events" to "authenticated";

grant update on table "public"."events" to "authenticated";

grant delete on table "public"."events" to "service_role";

grant insert on table "public"."events" to "service_role";

grant references on table "public"."events" to "service_role";

grant select on table "public"."events" to "service_role";

grant trigger on table "public"."events" to "service_role";

grant truncate on table "public"."events" to "service_role";

grant update on table "public"."events" to "service_role";

grant delete on table "public"."games" to "anon";

grant insert on table "public"."games" to "anon";

grant references on table "public"."games" to "anon";

grant select on table "public"."games" to "anon";

grant trigger on table "public"."games" to "anon";

grant truncate on table "public"."games" to "anon";

grant update on table "public"."games" to "anon";

grant delete on table "public"."games" to "authenticated";

grant insert on table "public"."games" to "authenticated";

grant references on table "public"."games" to "authenticated";

grant select on table "public"."games" to "authenticated";

grant trigger on table "public"."games" to "authenticated";

grant truncate on table "public"."games" to "authenticated";

grant update on table "public"."games" to "authenticated";

grant delete on table "public"."games" to "service_role";

grant insert on table "public"."games" to "service_role";

grant references on table "public"."games" to "service_role";

grant select on table "public"."games" to "service_role";

grant trigger on table "public"."games" to "service_role";

grant truncate on table "public"."games" to "service_role";

grant update on table "public"."games" to "service_role";

grant delete on table "public"."gameservers" to "anon";

grant insert on table "public"."gameservers" to "anon";

grant references on table "public"."gameservers" to "anon";

grant select on table "public"."gameservers" to "anon";

grant trigger on table "public"."gameservers" to "anon";

grant truncate on table "public"."gameservers" to "anon";

grant update on table "public"."gameservers" to "anon";

grant delete on table "public"."gameservers" to "authenticated";

grant insert on table "public"."gameservers" to "authenticated";

grant references on table "public"."gameservers" to "authenticated";

grant select on table "public"."gameservers" to "authenticated";

grant trigger on table "public"."gameservers" to "authenticated";

grant truncate on table "public"."gameservers" to "authenticated";

grant update on table "public"."gameservers" to "authenticated";

grant delete on table "public"."gameservers" to "service_role";

grant insert on table "public"."gameservers" to "service_role";

grant references on table "public"."gameservers" to "service_role";

grant select on table "public"."gameservers" to "service_role";

grant trigger on table "public"."gameservers" to "service_role";

grant truncate on table "public"."gameservers" to "service_role";

grant update on table "public"."gameservers" to "service_role";

grant delete on table "public"."links" to "anon";

grant insert on table "public"."links" to "anon";

grant references on table "public"."links" to "anon";

grant select on table "public"."links" to "anon";

grant trigger on table "public"."links" to "anon";

grant truncate on table "public"."links" to "anon";

grant update on table "public"."links" to "anon";

grant delete on table "public"."links" to "authenticated";

grant insert on table "public"."links" to "authenticated";

grant references on table "public"."links" to "authenticated";

grant select on table "public"."links" to "authenticated";

grant trigger on table "public"."links" to "authenticated";

grant truncate on table "public"."links" to "authenticated";

grant update on table "public"."links" to "authenticated";

grant delete on table "public"."links" to "service_role";

grant insert on table "public"."links" to "service_role";

grant references on table "public"."links" to "service_role";

grant select on table "public"."links" to "service_role";

grant trigger on table "public"."links" to "service_role";

grant truncate on table "public"."links" to "service_role";

grant update on table "public"."links" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."role_permissions" to "anon";

grant insert on table "public"."role_permissions" to "anon";

grant references on table "public"."role_permissions" to "anon";

grant select on table "public"."role_permissions" to "anon";

grant trigger on table "public"."role_permissions" to "anon";

grant truncate on table "public"."role_permissions" to "anon";

grant update on table "public"."role_permissions" to "anon";

grant delete on table "public"."role_permissions" to "authenticated";

grant insert on table "public"."role_permissions" to "authenticated";

grant references on table "public"."role_permissions" to "authenticated";

grant select on table "public"."role_permissions" to "authenticated";

grant trigger on table "public"."role_permissions" to "authenticated";

grant truncate on table "public"."role_permissions" to "authenticated";

grant update on table "public"."role_permissions" to "authenticated";

grant delete on table "public"."role_permissions" to "service_role";

grant insert on table "public"."role_permissions" to "service_role";

grant references on table "public"."role_permissions" to "service_role";

grant select on table "public"."role_permissions" to "service_role";

grant trigger on table "public"."role_permissions" to "service_role";

grant truncate on table "public"."role_permissions" to "service_role";

grant update on table "public"."role_permissions" to "service_role";

grant delete on table "public"."user_roles" to "anon";

grant insert on table "public"."user_roles" to "anon";

grant references on table "public"."user_roles" to "anon";

grant select on table "public"."user_roles" to "anon";

grant trigger on table "public"."user_roles" to "anon";

grant truncate on table "public"."user_roles" to "anon";

grant update on table "public"."user_roles" to "anon";

grant delete on table "public"."user_roles" to "authenticated";

grant insert on table "public"."user_roles" to "authenticated";

grant references on table "public"."user_roles" to "authenticated";

grant select on table "public"."user_roles" to "authenticated";

grant trigger on table "public"."user_roles" to "authenticated";

grant truncate on table "public"."user_roles" to "authenticated";

grant update on table "public"."user_roles" to "authenticated";

grant delete on table "public"."user_roles" to "service_role";

grant insert on table "public"."user_roles" to "service_role";

grant references on table "public"."user_roles" to "service_role";

grant select on table "public"."user_roles" to "service_role";

grant trigger on table "public"."user_roles" to "service_role";

grant truncate on table "public"."user_roles" to "service_role";

grant update on table "public"."user_roles" to "service_role";

create policy "Everyone can SELECT events"
on "public"."events"
as permissive
for select
to authenticated, anon
using (true);


create policy "Everyone can SELECT games"
on "public"."games"
as permissive
for select
to authenticated, anon
using (true);


create policy "Everyone can SELECT gameservers"
on "public"."gameservers"
as permissive
for select
to authenticated, anon
using (true);


create policy "Everyone can SELECT links"
on "public"."links"
as permissive
for select
to authenticated, anon
using (true);


create policy "Users can SELECT profiles"
on "public"."profiles"
as permissive
for select
to authenticated
using (true);


create policy "Users can UPDATE their profiles"
on "public"."profiles"
as permissive
for update
to authenticated
using ((( SELECT auth.uid() AS uid) = id))
with check ((( SELECT auth.uid() AS uid) = id));



