-- Rakett(er)
CREATE TABLE rocket (
  rocket_id     SERIAL PRIMARY KEY,
  name          TEXT NOT NULL,
  serial_number TEXT,
  notes         TEXT
);

-- Flyvninger (kobler data til en spesifikk flytur/mission)
CREATE TABLE flight (
  flight_id         SERIAL PRIMARY KEY,
  rocket_id         INT NOT NULL REFERENCES rocket(rocket_id),
  mission_name      TEXT,
  launch_site       TEXT,
  planned_launch_at TIMESTAMPTZ,   -- planlagt tidspunkt
  launch_at         TIMESTAMPTZ,   -- faktisk avfyring (når kjent)
  recover_at        TIMESTAMPTZ,   -- faktisk recovery
  notes             TEXT
);

-- Oppslag for tilstand (state) fra firmware
CREATE TABLE flight_state (
  state_id    INT PRIMARY KEY,     -- må matche verdien 'state' i telemetri
  name        TEXT NOT NULL,       -- f.eks. IDLE, ASCENT, APOGEE, osv.
  description TEXT
);

-- Telemetri (rad for hver mottatt pakke/linje)
CREATE TABLE telemetry (
  telemetry_id   BIGSERIAL PRIMARY KEY,
  flight_id      INT NOT NULL REFERENCES flight(flight_id),

  -- fra nyttelast/firmware
  seq            INT NOT NULL,          -- sekvensnr i flyvningen
  t_ms           BIGINT NOT NULL,       -- MCU-tid i millisekunder siden boot (parts[0])

  -- tidsstempler på bakkestasjon
  received_at    TIMESTAMPTZ NOT NULL DEFAULT now(),  -- når GS mottok pakken
  gps_time       TIMESTAMPTZ,           -- valgfritt: absolutt GPS/UTC om dere sender det senere

  -- sensorer
  ax             REAL,   -- m/s^2
  ay             REAL,
  az             REAL,
  pitch_deg      REAL,   -- grader
  roll_deg       REAL,
  yaw_deg        REAL,
  temperature_c  REAL,   -- °C
  velocity_mps   REAL,   -- m/s
  pressure_pa    REAL,   -- Pascal (statisk/absolutt – dokumenter)
  latitude_deg   DOUBLE PRECISION,
  longitude_deg  DOUBLE PRECISION,
  altitude_m     REAL,   -- meter (MSL/AGL – dokumenter!)
  state_id       INT REFERENCES flight_state(state_id),

  -- radio/diagnostikk (valgfrie)
  rssi_dbm       REAL,
  snr_db         REAL,
  raw_line       TEXT    -- rå CSV-linje for feilsøking
);

-- Hendelser (apogee, main deploy, GPS lock, osv.)
CREATE TABLE flight_event (
  event_id    BIGSERIAL PRIMARY KEY,
  flight_id   INT NOT NULL REFERENCES flight(flight_id),
  event_type  TEXT NOT NULL,     -- f.eks. 'APOGEE_DETECTED', 'MAIN_DEPLOY'
  t_ms        BIGINT,            -- MCU-tid for enkel matching mot telemetri
  at_time     TIMESTAMPTZ NOT NULL DEFAULT now(),  -- når GS registrerte hendelsen
  details     JSONB              -- valgfritt: ekstra data (høyde ved apogee, osv.)
);
