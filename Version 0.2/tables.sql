-- Rakett(er)
CREATE TABLE rocket (
  rocket_id     SERIAL PRIMARY KEY,
  name          TEXT NOT NULL
);

-- Flyvninger (kobler data til en spesifikk flytur/mission)
CREATE TABLE flight (
  flight_id         SERIAL PRIMARY KEY,
  rocket_id         INT NOT NULL REFERENCES rocket(rocket_id),
  mission_name      TEXT,
  launch_site       TEXT,
  planned_launch_at TIMESTAMPTZ,   -- planlagt tidspunkt
  launch_at         TIMESTAMPTZ,   -- faktisk avfyring (når kjent)
  recover_at        TIMESTAMPTZ   -- faktisk recovery
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

  -- fra flight computer
  t_ms           BIGINT NOT NULL,       -- MCU-tid i millisekunder siden boot (parts[0])

  -- tidsstempler på bakkestasjon
  received_at    TIMESTAMPTZ NOT NULL DEFAULT now(),  -- når GS mottok pakken

  -- sensorer
  ax             REAL,   -- m/s^2
  ay             REAL,
  az             REAL,
  pitch_deg      REAL,   -- grader
  roll_deg       REAL,
  yaw_deg        REAL,
  temperature_c  REAL,   -- °C
  velocity		 REAL,   -- m/s
  pressure_pa    REAL,   -- Pascal (statisk/absolutt – dokumenter)
  latitude_deg   DOUBLE PRECISION,
  longitude_deg  DOUBLE PRECISION,
  altitude_m     REAL,   -- meter (MSL/AGL – dokumenter!)
  state_id       INT REFERENCES flight_state(state_id)
);
