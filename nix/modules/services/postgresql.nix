{ pkgs, username, ... }:

{
  # Local PostgreSQL for development. Listens on localhost only.
  services.postgresql = {
    enable = true;
    # Pinned explicitly: a major-version bump needs a manual data migration
    # (pg_upgrade), so it must never happen as a side effect of a flake update.
    package = pkgs.postgresql_18;

    # Role and database named after the user, so `psql` works without flags
    # via peer auth over the unix socket (the default local auth method).
    ensureDatabases = [ username ];
    ensureUsers = [
      {
        name = username;
        ensureDBOwnership = true;
        ensureClauses = {
          createdb = true;
          createrole = true;
        };
      }
    ];
  };
}
