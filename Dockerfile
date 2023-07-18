FROM rust:latest as build


ENV build_deps build-essential \
  libpq-dev \
  postgresql \
  postgresql-server-dev-15 \
  curl \
  zlib1g-dev \
  libclang-dev


RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update
RUN apt-get install -y --no-install-recommends $build_deps pkg-config cmake flex

RUN useradd --user-group --system --create-home --no-log-init app
RUN usermod -aG sudo app
RUN chown -R app /home/app
USER app


WORKDIR /home/app
RUN git clone https://github.com/VADOSWARE/pg_idkit.git pg_idkit
WORKDIR /home/app/pg_idkit
RUN git reset --hard 5c93c4b03f06256e3a659f10655389b366c9ddb1

RUN cargo install cargo-pgrx@0.9.7
RUN cargo pgrx init --pg15 $(which pg_config)
RUN make package

FROM supabase/postgres:15.1.0.90

RUN sed -i -e "s|shared_preload_libraries = '\(.*\)'|shared_preload_libraries = '\1, pg_idkit'|" /etc/postgresql/postgresql.conf

# SHAREDIR should be /usr/local/share/postgresql (pg_config --sharedir)
COPY --from=build /home/app/pg_idkit/target/release/pg_idkit-pg15/usr/lib/postgresql/15/lib/pg_idkit.so /usr/lib/postgresql/15/lib/pg_idkit.so
COPY --from=build /home/app/pg_idkit/target/release/pg_idkit-pg15/usr/share/postgresql/15/extension/pg_idkit.control /usr/share/postgresql/15/extension/pg_idkit.control
COPY --from=build /home/app/pg_idkit/target/release/pg_idkit-pg15/usr/share/postgresql/15/extension/pg_idkit--0.1.0.sql /usr/share/postgresql/15/extension/pg_idkit--0.1.0.sql
