-- ============================================================
-- ParkingSpaceSharingDB — Supabase Auth-ready schema + seed
-- ============================================================
-- NOTES:
--   • users.id is UUID, linked to auth.users (Supabase owns auth)
--   • password_hash removed — Supabase Auth handles credentials
--   • user_auth_providers removed — Supabase Auth handles OAuth
--   • All FK references to users use UUID
--   • Trigger auto-creates a public.users row on auth signup
-- ============================================================


-- ========================
-- EXTENSIONS
-- ========================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ========================
-- ENUM TYPES
-- ========================

CREATE TYPE user_role AS ENUM ('DRIVER', 'OWNER', 'ADMIN', 'SUPER_ADMIN');

CREATE TYPE verification_status AS ENUM ('UNVERIFIED', 'PENDING', 'VERIFIED', 'REJECTED');

CREATE TYPE vehicle_type AS ENUM ('CAR', 'MOTORCYCLE', 'VAN', 'TRUCK', 'ELECTRIC');

CREATE TYPE spot_type AS ENUM ('OUTDOOR', 'INDOOR', 'COVERED', 'VALET', 'GARAGE', 'STREET');

CREATE TYPE spot_status AS ENUM ('AVAILABLE', 'ARCHIVED', 'SUSPENDED');

CREATE TYPE amenity AS ENUM ('CCTV', 'LIGHTING', 'EV_CHARGER', 'WHEELCHAIR', 'GUARD', 'CAR_WASH');

CREATE TYPE reservation_status AS ENUM ('PENDING', 'CONFIRMED', 'ACTIVE', 'COMPLETED', 'CANCELLED', 'EXPIRED', 'REFUNDED');

CREATE TYPE payment_status AS ENUM ('PENDING', 'SUCCEEDED', 'FAILED', 'REFUNDED');

CREATE TYPE payment_method AS ENUM ('CARD', 'APPLE_PAY', 'GOOGLE_PAY');

CREATE TYPE notification_type AS ENUM (
  'RESERVATION_CONFIRMED',
  'RESERVATION_CANCELLED',
  'PAYMENT_SUCCESS',
  'PAYMENT_FAILED',
  'REVIEW_RECEIVED',
  'EXPIRY_REMINDER',
  'ACCOUNT_VERIFIED',
  'DISPUTE_UPDATE',
  'SYSTEM'
);

CREATE TYPE notification_channel AS ENUM ('PUSH', 'EMAIL', 'IN_APP');

CREATE TYPE report_target_type AS ENUM ('USER', 'PARKING_SPOT', 'REVIEW');

CREATE TYPE report_reason AS ENUM ('FAKE_LISTING', 'SPAM', 'INAPPROPRIATE', 'FRAUD', 'WRONG_LOCATION');

CREATE TYPE report_status AS ENUM ('PENDING', 'RESOLVED', 'DISMISSED');


-- ========================
-- TABLES
-- ========================

-- Users (mirrors auth.users — one row per auth account)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  first_name VARCHAR NOT NULL,
  last_name  VARCHAR NOT NULL,

  email VARCHAR UNIQUE,
  phone VARCHAR UNIQUE,

  profile_photo VARCHAR,

  role                user_role           NOT NULL DEFAULT 'DRIVER',
  verification_status verification_status NOT NULL DEFAULT 'UNVERIFIED',

  identity_doc VARCHAR,

  is_suspended  BOOLEAN   NOT NULL DEFAULT false,
  suspension_at TIMESTAMP,
  suspension_end TIMESTAMP,

  is_banned BOOLEAN NOT NULL DEFAULT false,

  average_rating FLOAT NOT NULL DEFAULT 0,
  total_reviews  INT   NOT NULL DEFAULT 0,

  fcm_token VARCHAR,

  created_at    TIMESTAMP NOT NULL DEFAULT now(),
  updated_at    TIMESTAMP NOT NULL DEFAULT now(),
  last_login_at TIMESTAMP
);


CREATE TABLE vehicles (
  id SERIAL PRIMARY KEY,

  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  plate_number VARCHAR UNIQUE NOT NULL,
  type         vehicle_type   NOT NULL,
  brand        VARCHAR        NOT NULL,
  model        VARCHAR        NOT NULL,
  color        VARCHAR        NOT NULL,

  is_default BOOLEAN NOT NULL DEFAULT false,

  created_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE parking_lots (
  id SERIAL PRIMARY KEY,

  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  name        VARCHAR NOT NULL,
  description TEXT,

  latitude  FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  altitude  FLOAT,

  street      VARCHAR NOT NULL,
  city        VARCHAR NOT NULL,
  country     VARCHAR NOT NULL,
  postal_code VARCHAR NOT NULL,

  photos    TEXT[],
  amenities amenity[],

  total_spots INT,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE parking_spots (
  id SERIAL PRIMARY KEY,

  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lot_id   INT  REFERENCES parking_lots(id) ON DELETE SET NULL,

  title       VARCHAR NOT NULL,
  description TEXT,

  latitude  FLOAT,
  longitude FLOAT,
  altitude  FLOAT,

  street      VARCHAR,
  city        VARCHAR,
  country     VARCHAR,
  postal_code VARCHAR,

  photos TEXT[],

  price_per_hour FLOAT NOT NULL,
  price_per_day  FLOAT,

  spot_type     spot_type    NOT NULL,
  vehicle_types vehicle_type[],
  amenities     amenity[],

  status spot_status NOT NULL DEFAULT 'AVAILABLE',

  average_rating FLOAT NOT NULL DEFAULT 0,
  total_reviews  INT   NOT NULL DEFAULT 0,
  total_bookings INT   NOT NULL DEFAULT 0,

  is_dynamic_pricing BOOLEAN NOT NULL DEFAULT false,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE reservations (
  id SERIAL PRIMARY KEY,

  driver_id  UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  spot_id    INT  NOT NULL REFERENCES parking_spots(id) ON DELETE RESTRICT,
  vehicle_id INT  NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,

  start_time TIMESTAMP NOT NULL,
  end_time   TIMESTAMP NOT NULL,

  status reservation_status NOT NULL DEFAULT 'PENDING',

  total_price  FLOAT NOT NULL,
  platform_fee FLOAT NOT NULL,

  lock_expires_at     TIMESTAMP,
  cancellation_reason TEXT,
  access_code         VARCHAR,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE payments (
  id SERIAL PRIMARY KEY,

  reservation_id INT  UNIQUE NOT NULL REFERENCES reservations(id) ON DELETE RESTRICT,
  payer_id       UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,

  amount       FLOAT NOT NULL,
  platform_fee FLOAT NOT NULL,
  owner_payout FLOAT NOT NULL,

  currency VARCHAR NOT NULL DEFAULT 'MAD',

  status payment_status NOT NULL DEFAULT 'PENDING',
  method payment_method NOT NULL,

  stripe_payment_intent_id VARCHAR,
  stripe_charge_id         VARCHAR,

  refund_id     VARCHAR,
  refund_amount FLOAT,

  retry_count INT NOT NULL DEFAULT 0,

  invoice_url VARCHAR,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,

  reservation_id INT  UNIQUE NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
  reviewer_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  spot_id        INT  NOT NULL REFERENCES parking_spots(id) ON DELETE CASCADE,

  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),

  comment           TEXT,
  owner_reply       TEXT,
  owner_replied_at  TIMESTAMP,

  is_visible BOOLEAN NOT NULL DEFAULT true,

  created_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,

  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  type    notification_type    NOT NULL,
  channel notification_channel NOT NULL,

  title   VARCHAR NOT NULL,
  content TEXT    NOT NULL,

  reference_id   INT,
  reference_type VARCHAR,

  is_read BOOLEAN   NOT NULL DEFAULT false,
  sent_at TIMESTAMP,

  created_at TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE reports (
  id SERIAL PRIMARY KEY,

  reporter_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  target_id   INT                NOT NULL,
  target_type report_target_type NOT NULL,

  reason      report_reason NOT NULL,
  description TEXT,

  status      report_status NOT NULL DEFAULT 'PENDING',
  resolved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  resolution  TEXT,

  created_at  TIMESTAMP NOT NULL DEFAULT now(),
  resolved_at TIMESTAMP
);


CREATE TABLE wishlists (
  id SERIAL PRIMARY KEY,

  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  spot_id INT  NOT NULL REFERENCES parking_spots(id) ON DELETE CASCADE,

  added_at TIMESTAMP NOT NULL DEFAULT now(),

  UNIQUE (user_id, spot_id)
);


CREATE TABLE availabilities (
  id SERIAL PRIMARY KEY,

  spot_id INT NOT NULL REFERENCES parking_spots(id) ON DELETE CASCADE,

  day_of_week   INT  CHECK (day_of_week BETWEEN 0 AND 6),
  specific_date DATE,

  open_time  TIME NOT NULL,
  close_time TIME NOT NULL,

  is_blocked BOOLEAN NOT NULL DEFAULT false
);


CREATE TABLE dynamic_pricing_rules (
  id SERIAL PRIMARY KEY,

  spot_id INT NOT NULL REFERENCES parking_spots(id) ON DELETE CASCADE,

  three_hours  DOUBLE PRECISION,
  six_hours    DOUBLE PRECISION,
  twelve_hours DOUBLE PRECISION,

  is_active BOOLEAN NOT NULL DEFAULT true
);


-- ========================
-- ROW LEVEL SECURITY
-- ========================

ALTER TABLE users               ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles            ENABLE ROW LEVEL SECURITY;
ALTER TABLE parking_lots        ENABLE ROW LEVEL SECURITY;
ALTER TABLE parking_spots       ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations        ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments            ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews             ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports             ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists           ENABLE ROW LEVEL SECURITY;
ALTER TABLE availabilities      ENABLE ROW LEVEL SECURITY;
ALTER TABLE dynamic_pricing_rules ENABLE ROW LEVEL SECURITY;

-- Users: read own profile; admins read all
CREATE POLICY "users_read_own"   ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "users_update_own" ON users FOR UPDATE USING (auth.uid() = id);

-- Vehicles: own only
CREATE POLICY "vehicles_own" ON vehicles FOR ALL USING (auth.uid() = owner_id);

-- Parking lots & spots: owners manage theirs; everyone reads available spots
CREATE POLICY "lots_owner_manage" ON parking_lots FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "spots_read_all"    ON parking_spots FOR SELECT USING (status = 'AVAILABLE');
CREATE POLICY "spots_owner_manage" ON parking_spots FOR ALL USING (auth.uid() = owner_id);

-- Reservations: driver or spot owner
CREATE POLICY "reservations_driver" ON reservations FOR ALL USING (auth.uid() = driver_id);

-- Payments: payer only
CREATE POLICY "payments_payer" ON payments FOR SELECT USING (auth.uid() = payer_id);

-- Reviews: visible to all; reviewer manages own
CREATE POLICY "reviews_read_visible" ON reviews FOR SELECT USING (is_visible = true);
CREATE POLICY "reviews_own"          ON reviews FOR ALL USING (auth.uid() = reviewer_id);

-- Notifications: own only
CREATE POLICY "notifications_own" ON notifications FOR ALL USING (auth.uid() = user_id);

-- Wishlists: own only
CREATE POLICY "wishlists_own" ON wishlists FOR ALL USING (auth.uid() = user_id);

-- Availabilities & pricing: public read, owner write (via spot ownership)
CREATE POLICY "availabilities_read"  ON availabilities      FOR SELECT USING (true);
CREATE POLICY "pricing_read"         ON dynamic_pricing_rules FOR SELECT USING (true);

-- Reports: reporter reads own
CREATE POLICY "reports_own" ON reports FOR SELECT USING (auth.uid() = reporter_id);


-- ========================
-- AUTH TRIGGER
-- ========================
-- Automatically creates a public.users row when a new
-- Supabase Auth account is registered.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, first_name, last_name, phone, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'last_name',  ''),
    NEW.raw_user_meta_data->>'phone',
    COALESCE(
      (NEW.raw_user_meta_data->>'role')::user_role,
      'DRIVER'
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- ============================================================
-- SEED DATA
-- ============================================================
-- UUIDs are fixed so FK references stay consistent.
-- In a real migration you would create these users via the
-- Supabase Auth Admin API first, then run this seed.
-- ============================================================


-- ========================
-- TEARDOWN
-- ========================

TRUNCATE TABLE
  reports,
  wishlists,
  notifications,
  reviews,
  payments,
  reservations,
  dynamic_pricing_rules,
  availabilities,
  parking_spots,
  parking_lots,
  vehicles,
  users
RESTART IDENTITY CASCADE;


-- ========================
-- SEED: USERS
-- (These UUIDs must already exist in auth.users)
-- ========================

INSERT INTO users (id, first_name, last_name, email, phone, profile_photo, role, verification_status, is_suspended, is_banned, average_rating, total_reviews, created_at, updated_at, last_login_at) VALUES
('00000000-0000-0000-0000-000000000001', 'Youssef',  'El Amrani',  'youssef.elamrani@gmail.com',  '+212661001001', 'https://i.pravatar.cc/150?img=1',  'DRIVER',     'VERIFIED',   false, false, 4.8, 12, now() - interval '180 days', now() - interval '1 day',    now() - interval '1 day'),
('00000000-0000-0000-0000-000000000002', 'Fatima',   'Benali',     'fatima.benali@gmail.com',      '+212661002002', 'https://i.pravatar.cc/150?img=5',  'DRIVER',     'VERIFIED',   false, false, 4.5, 8,  now() - interval '120 days', now() - interval '2 days',   now() - interval '2 days'),
('00000000-0000-0000-0000-000000000003', 'Karim',    'Tazi',       'karim.tazi@outlook.com',       '+212661003003', 'https://i.pravatar.cc/150?img=3',  'OWNER',      'VERIFIED',   false, false, 4.9, 35, now() - interval '365 days', now() - interval '3 hours',  now() - interval '3 hours'),
('00000000-0000-0000-0000-000000000004', 'Nadia',    'Chaoui',     'nadia.chaoui@hotmail.com',     '+212661004004', 'https://i.pravatar.cc/150?img=9',  'OWNER',      'VERIFIED',   false, false, 4.7, 22, now() - interval '300 days', now() - interval '5 hours',  now() - interval '5 hours'),
('00000000-0000-0000-0000-000000000005', 'Mehdi',    'Fassi',      'mehdi.fassi@gmail.com',        '+212661005005', 'https://i.pravatar.cc/150?img=7',  'DRIVER',     'VERIFIED',   false, false, 4.2, 5,  now() - interval '90 days',  now() - interval '1 day',    now() - interval '1 day'),
('00000000-0000-0000-0000-000000000006', 'Samira',   'Alaoui',     'samira.alaoui@gmail.com',      '+212661006006', 'https://i.pravatar.cc/150?img=10', 'DRIVER',     'PENDING',    false, false, 0.0, 0,  now() - interval '10 days',  now() - interval '10 days',  now() - interval '10 days'),
('00000000-0000-0000-0000-000000000007', 'Omar',     'Benkiran',   'omar.benkiran@gmail.com',      '+212661007007', 'https://i.pravatar.cc/150?img=12', 'OWNER',      'VERIFIED',   false, false, 4.6, 18, now() - interval '200 days', now() - interval '6 hours',  now() - interval '6 hours'),
('00000000-0000-0000-0000-000000000008', 'Laila',    'Rahimi',     'laila.rahimi@gmail.com',       '+212661008008', 'https://i.pravatar.cc/150?img=16', 'DRIVER',     'VERIFIED',   false, false, 3.8, 4,  now() - interval '60 days',  now() - interval '3 days',   now() - interval '3 days'),
('00000000-0000-0000-0000-000000000009', 'Hassan',   'Idrissi',    'hassan.idrissi@gmail.com',     '+212661009009', 'https://i.pravatar.cc/150?img=20', 'DRIVER',     'UNVERIFIED', false, false, 0.0, 0,  now() - interval '5 days',   now() - interval '5 days',   now() - interval '5 days'),
('00000000-0000-0000-0000-000000000010', 'Zineb',    'Moussaoui',  'zineb.moussaoui@gmail.com',    '+212661010010', 'https://i.pravatar.cc/150?img=25', 'DRIVER',     'VERIFIED',   false, false, 4.1, 7,  now() - interval '150 days', now() - interval '12 hours', now() - interval '12 hours'),
('00000000-0000-0000-0000-000000000011', 'Rachid',   'Admin',      'rachid.admin@parkma.com',      '+212661011011', 'https://i.pravatar.cc/150?img=30', 'ADMIN',      'VERIFIED',   false, false, 0.0, 0,  now() - interval '500 days', now() - interval '1 hour',   now() - interval '1 hour'),
('00000000-0000-0000-0000-000000000012', 'Imane',    'Suspended',  'imane.test@gmail.com',         '+212661012012', 'https://i.pravatar.cc/150?img=32', 'DRIVER',     'VERIFIED',   true,  false, 2.1, 3,  now() - interval '40 days',  now() - interval '20 days',  now() - interval '20 days');


-- ========================
-- SEED: VEHICLES
-- ========================

INSERT INTO vehicles (id, owner_id, plate_number, type, brand, model, color, is_default, created_at) VALUES
(1,  '00000000-0000-0000-0000-000000000001', 'A-12345-B', 'CAR',        'Toyota',   'Corolla',  'White',       true,  now() - interval '170 days'),
(2,  '00000000-0000-0000-0000-000000000001', 'A-67890-B', 'MOTORCYCLE', 'Honda',    'CB500',    'Black',       false, now() - interval '60 days'),
(3,  '00000000-0000-0000-0000-000000000002', 'B-11111-C', 'CAR',        'Dacia',    'Logan',    'Silver',      true,  now() - interval '110 days'),
(4,  '00000000-0000-0000-0000-000000000005', 'C-22222-D', 'CAR',        'Renault',  'Clio',     'Blue',        true,  now() - interval '80 days'),
(5,  '00000000-0000-0000-0000-000000000008', 'D-33333-E', 'VAN',        'Mercedes', 'Sprinter', 'White',       true,  now() - interval '55 days'),
(6,  '00000000-0000-0000-0000-000000000010', 'E-44444-F', 'CAR',        'Peugeot',  '208',      'Red',         true,  now() - interval '140 days'),
(7,  '00000000-0000-0000-0000-000000000010', 'E-55555-F', 'ELECTRIC',   'Tesla',    'Model 3',  'Pearl White', false, now() - interval '20 days'),
(8,  '00000000-0000-0000-0000-000000000006', 'F-66666-G', 'CAR',        'Hyundai',  'i20',      'Grey',        true,  now() - interval '8 days'),
(9,  '00000000-0000-0000-0000-000000000012', 'G-77777-H', 'CAR',        'Kia',      'Picanto',  'Green',       true,  now() - interval '35 days');

SELECT setval('vehicles_id_seq', 9);


-- ========================
-- SEED: PARKING LOTS
-- ========================

INSERT INTO parking_lots (id, owner_id, name, description, latitude, longitude, street, city, country, postal_code, photos, amenities, total_spots, created_at, updated_at) VALUES
(1, '00000000-0000-0000-0000-000000000003',
 'Gueliz Premium Parking',
 'A fully covered multi-level parking facility in the heart of Gueliz, Marrakesh. Secure, well-lit with 24/7 CCTV surveillance.',
 31.6355, -8.0083, 'Avenue Mohammed V', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/lot1a/800/500','https://picsum.photos/seed/lot1b/800/500','https://picsum.photos/seed/lot1c/800/500'],
 ARRAY['CCTV','LIGHTING','GUARD']::amenity[], 40,
 now() - interval '360 days', now() - interval '5 days'),

(2, '00000000-0000-0000-0000-000000000004',
 'Hivernage Secure Park',
 'Modern underground parking adjacent to the luxury hotels of Hivernage district. EV charging available.',
 31.6275, -8.0100, 'Avenue Echouhada', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/lot2a/800/500','https://picsum.photos/seed/lot2b/800/500'],
 ARRAY['CCTV','LIGHTING','EV_CHARGER','GUARD','WHEELCHAIR']::amenity[], 25,
 now() - interval '280 days', now() - interval '10 days'),

(3, '00000000-0000-0000-0000-000000000007',
 'Medina Gate Parking',
 'Open-air lot near Bab Doukkala — convenient for Medina access. Attendant on duty from 7am to midnight.',
 31.6340, -7.9910, 'Rue Bab Doukkala', 'Marrakesh', 'Morocco', '40008',
 ARRAY['https://picsum.photos/seed/lot3a/800/500','https://picsum.photos/seed/lot3b/800/500'],
 ARRAY['CCTV','LIGHTING']::amenity[], 30,
 now() - interval '190 days', now() - interval '2 days');

SELECT setval('parking_lots_id_seq', 3);


-- ========================
-- SEED: PARKING SPOTS
-- ========================

INSERT INTO parking_spots (id, owner_id, lot_id, title, description, latitude, longitude, street, city, country, postal_code, photos, price_per_hour, price_per_day, spot_type, vehicle_types, amenities, status, average_rating, total_reviews, total_bookings, is_dynamic_pricing, created_at, updated_at) VALUES

(1, '00000000-0000-0000-0000-000000000003', 1,
 'Covered Spot A1 – Gueliz', 'Ground floor, covered spot near the elevator. Easy in/out. Ideal for daily parking.',
 31.6355, -8.0083, 'Avenue Mohammed V', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/spot1a/800/500','https://picsum.photos/seed/spot1b/800/500'],
 8.0, 60.0, 'COVERED', ARRAY['CAR','MOTORCYCLE']::vehicle_type[], ARRAY['CCTV','LIGHTING']::amenity[],
 'AVAILABLE', 4.9, 21, 45, true, now() - interval '355 days', now() - interval '1 day'),

(2, '00000000-0000-0000-0000-000000000003', 1,
 'Covered Spot B3 – Gueliz', 'Second floor, covered, suitable for larger vehicles. CCTV coverage.',
 31.6356, -8.0082, 'Avenue Mohammed V', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/spot2a/800/500'],
 7.0, 50.0, 'GARAGE', ARRAY['CAR','VAN']::vehicle_type[], ARRAY['CCTV','LIGHTING','GUARD']::amenity[],
 'AVAILABLE', 4.6, 14, 30, false, now() - interval '355 days', now() - interval '2 days'),

(3, '00000000-0000-0000-0000-000000000004', 2,
 'EV Bay – Hivernage Underground', 'Underground spot with Tesla-compatible EV charger. Perfect for electric vehicles.',
 31.6275, -8.0100, 'Avenue Echouhada', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/spot3a/800/500','https://picsum.photos/seed/spot3b/800/500','https://picsum.photos/seed/spot3c/800/500'],
 12.0, 90.0, 'INDOOR', ARRAY['ELECTRIC','CAR']::vehicle_type[], ARRAY['CCTV','LIGHTING','EV_CHARGER','WHEELCHAIR']::amenity[],
 'AVAILABLE', 4.8, 19, 38, true, now() - interval '275 days', now() - interval '3 days'),

(4, '00000000-0000-0000-0000-000000000004', 2,
 'Standard Bay – Hivernage', 'Standard underground spot. Wheelchair-accessible path to elevator.',
 31.6276, -8.0099, 'Avenue Echouhada', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/spot4a/800/500'],
 9.0, 65.0, 'INDOOR', ARRAY['CAR']::vehicle_type[], ARRAY['CCTV','LIGHTING','WHEELCHAIR']::amenity[],
 'AVAILABLE', 4.5, 11, 22, false, now() - interval '275 days', now() - interval '5 days'),

(5, '00000000-0000-0000-0000-000000000007', 3,
 'Outdoor Space – Bab Doukkala', 'Open-air spot right next to Bab Doukkala gate. Attendant monitored.',
 31.6340, -7.9910, 'Rue Bab Doukkala', 'Marrakesh', 'Morocco', '40008',
 ARRAY['https://picsum.photos/seed/spot5a/800/500','https://picsum.photos/seed/spot5b/800/500'],
 5.0, 35.0, 'OUTDOOR', ARRAY['CAR','MOTORCYCLE']::vehicle_type[], ARRAY['CCTV','LIGHTING']::amenity[],
 'AVAILABLE', 4.3, 17, 55, false, now() - interval '185 days', now() - interval '1 day'),

(6, '00000000-0000-0000-0000-000000000003', NULL,
 'Private Garage – Semlalia', 'Private residential garage in the Semlalia district. Clean, secure, with roller shutter.',
 31.6420, -8.0120, 'Rue de la Liberté', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/spot6a/800/500','https://picsum.photos/seed/spot6b/800/500'],
 10.0, 70.0, 'GARAGE', ARRAY['CAR']::vehicle_type[], ARRAY['CCTV']::amenity[],
 'AVAILABLE', 4.7, 9, 18, false, now() - interval '200 days', now() - interval '4 days'),

(7, '00000000-0000-0000-0000-000000000007', NULL,
 'Street Spot – Majorelle Area', 'Monitored street parking near the Majorelle Garden. Available 8am–8pm.',
 31.6442, -8.0030, 'Rue Yves Saint Laurent', 'Marrakesh', 'Morocco', '40090',
 ARRAY['https://picsum.photos/seed/spot7a/800/500'],
 4.0, NULL, 'STREET', ARRAY['CAR','MOTORCYCLE']::vehicle_type[], ARRAY['LIGHTING']::amenity[],
 'AVAILABLE', 3.9, 6, 28, false, now() - interval '150 days', now() - interval '6 days'),

(8, '00000000-0000-0000-0000-000000000004', NULL,
 'Valet Service – Palmeraie', 'Premium valet parking at a private villa in the Palmeraie. Car wash available.',
 31.6650, -7.9600, 'Route de Fès', 'Marrakesh', 'Morocco', '40000',
 ARRAY['https://picsum.photos/seed/spot8a/800/500','https://picsum.photos/seed/spot8b/800/500','https://picsum.photos/seed/spot8c/800/500'],
 20.0, 150.0, 'VALET', ARRAY['CAR']::vehicle_type[], ARRAY['CCTV','LIGHTING','GUARD','CAR_WASH']::amenity[],
 'AVAILABLE', 5.0, 4, 12, true, now() - interval '90 days', now() - interval '1 day');

SELECT setval('parking_spots_id_seq', 8);


-- ========================
-- SEED: AVAILABILITIES
-- ========================

INSERT INTO availabilities (spot_id, day_of_week, open_time, close_time, is_blocked) VALUES
-- Spot 1: Mon–Fri 7am–10pm, Sat–Sun 8am–8pm
(1,1,'07:00','22:00',false),(1,2,'07:00','22:00',false),(1,3,'07:00','22:00',false),
(1,4,'07:00','22:00',false),(1,5,'07:00','22:00',false),
(1,6,'08:00','20:00',false),(1,0,'08:00','20:00',false),
-- Spot 3: 24/7
(3,0,'00:00','23:59',false),(3,1,'00:00','23:59',false),(3,2,'00:00','23:59',false),
(3,3,'00:00','23:59',false),(3,4,'00:00','23:59',false),(3,5,'00:00','23:59',false),
(3,6,'00:00','23:59',false),
-- Spot 5: daily 7am–midnight
(5,0,'07:00','00:00',false),(5,1,'07:00','00:00',false),(5,2,'07:00','00:00',false),
(5,3,'07:00','00:00',false),(5,4,'07:00','00:00',false),(5,5,'07:00','00:00',false),
(5,6,'07:00','00:00',false),
-- Spot 7: daily 8am–8pm
(7,0,'08:00','20:00',false),(7,1,'08:00','20:00',false),(7,2,'08:00','20:00',false),
(7,3,'08:00','20:00',false),(7,4,'08:00','20:00',false),(7,5,'08:00','20:00',false),
(7,6,'08:00','20:00',false);

-- Spot 1: blocked on New Year's Day
INSERT INTO availabilities (spot_id, day_of_week, specific_date, open_time, close_time, is_blocked) VALUES
(1, NULL, '2025-01-01', '00:00', '23:59', true);


-- ========================
-- SEED: DYNAMIC PRICING
-- ========================

INSERT INTO dynamic_pricing_rules (spot_id, three_hours, six_hours, twelve_hours, is_active) VALUES
(1, 20.0,  36.0,  60.0,  true),
(3, 30.0,  55.0,  90.0,  true),
(8, 55.0, 100.0, 150.0,  true);


-- ========================
-- SEED: RESERVATIONS
-- ========================

INSERT INTO reservations (id, driver_id, spot_id, vehicle_id, start_time, end_time, status, total_price, platform_fee, access_code, created_at, updated_at) VALUES
(1,  '00000000-0000-0000-0000-000000000001', 1, 1, now()-interval'60 days',               now()-interval'60 days'+interval'3 hours',  'COMPLETED', 24.0,  3.60,  'AC1001', now()-interval'61 days',       now()-interval'60 days'),
(2,  '00000000-0000-0000-0000-000000000002', 5, 3, now()-interval'45 days',               now()-interval'45 days'+interval'2 hours',  'COMPLETED', 10.0,  1.50,  'AC1002', now()-interval'46 days',       now()-interval'45 days'),
(3,  '00000000-0000-0000-0000-000000000001', 3, 7, now()-interval'30 days',               now()-interval'30 days'+interval'4 hours',  'COMPLETED', 48.0,  7.20,  'AC1003', now()-interval'31 days',       now()-interval'30 days'),
(4,  '00000000-0000-0000-0000-000000000010', 8, 6, now()-interval'20 days',               now()-interval'20 days'+interval'8 hours',  'COMPLETED', 160.0, 24.0,  'AC1004', now()-interval'21 days',       now()-interval'20 days'),
(5,  '00000000-0000-0000-0000-000000000005', 2, 4, now()-interval'15 days',               now()-interval'15 days'+interval'5 hours',  'COMPLETED', 35.0,  5.25,  'AC1005', now()-interval'16 days',       now()-interval'15 days'),
(6,  '00000000-0000-0000-0000-000000000008', 6, 5, now()-interval'10 days',               now()-interval'10 days'+interval'6 hours',  'COMPLETED', 60.0,  9.00,  'AC1006', now()-interval'11 days',       now()-interval'10 days'),
(7,  '00000000-0000-0000-0000-000000000002', 1, 3, now()-interval'7 days',                now()-interval'7 days' +interval'2 hours',  'CANCELLED', 16.0,  2.40,  NULL,     now()-interval'8 days',        now()-interval'7 days'),
(8,  '00000000-0000-0000-0000-000000000001', 1, 1, now()+interval'1 day',                 now()+interval'1 day'  +interval'3 hours',  'CONFIRMED', 24.0,  3.60,  'AC1008', now()-interval'2 hours',       now()-interval'2 hours'),
(9,  '00000000-0000-0000-0000-000000000010', 3, 7, now()+interval'2 days',                now()+interval'2 days' +interval'8 hours',  'CONFIRMED', 90.0,  13.50, 'AC1009', now()-interval'1 day',         now()-interval'1 day'),
(10, '00000000-0000-0000-0000-000000000005', 5, 4, now()-interval'1 hour',                now()+interval'2 hours',                    'ACTIVE',    15.0,  2.25,  'AC1010', now()-interval'2 hours',       now()-interval'1 hour'),
(11, '00000000-0000-0000-0000-000000000006', 7, 8, now()+interval'3 days',                now()+interval'3 days' +interval'2 hours',  'PENDING',   8.0,   1.20,  NULL,     now()-interval'30 minutes',    now()-interval'30 minutes');

SELECT setval('reservations_id_seq', 11);


-- ========================
-- SEED: PAYMENTS
-- ========================

INSERT INTO payments (id, reservation_id, payer_id, amount, platform_fee, owner_payout, currency, status, method, stripe_payment_intent_id, stripe_charge_id, retry_count, created_at, updated_at) VALUES
(1,  1,  '00000000-0000-0000-0000-000000000001', 24.0,  3.60,  20.40, 'MAD', 'SUCCEEDED', 'CARD',       'pi_stripe_001', 'ch_stripe_001', 0, now()-interval'61 days',      now()-interval'60 days'),
(2,  2,  '00000000-0000-0000-0000-000000000002', 10.0,  1.50,  8.50,  'MAD', 'SUCCEEDED', 'GOOGLE_PAY', 'pi_stripe_002', 'ch_stripe_002', 0, now()-interval'46 days',      now()-interval'45 days'),
(3,  3,  '00000000-0000-0000-0000-000000000001', 48.0,  7.20,  40.80, 'MAD', 'SUCCEEDED', 'CARD',       'pi_stripe_003', 'ch_stripe_003', 0, now()-interval'31 days',      now()-interval'30 days'),
(4,  4,  '00000000-0000-0000-0000-000000000010', 160.0, 24.0,  136.0, 'MAD', 'SUCCEEDED', 'CARD',       'pi_stripe_004', 'ch_stripe_004', 0, now()-interval'21 days',      now()-interval'20 days'),
(5,  5,  '00000000-0000-0000-0000-000000000005', 35.0,  5.25,  29.75, 'MAD', 'SUCCEEDED', 'APPLE_PAY',  'pi_stripe_005', 'ch_stripe_005', 0, now()-interval'16 days',      now()-interval'15 days'),
(6,  6,  '00000000-0000-0000-0000-000000000008', 60.0,  9.00,  51.0,  'MAD', 'SUCCEEDED', 'CARD',       'pi_stripe_006', 'ch_stripe_006', 0, now()-interval'11 days',      now()-interval'10 days'),
(7,  7,  '00000000-0000-0000-0000-000000000002', 16.0,  2.40,  13.60, 'MAD', 'REFUNDED',  'CARD',       'pi_stripe_007', 'ch_stripe_007', 0, now()-interval'8 days',       now()-interval'7 days'),
(8,  8,  '00000000-0000-0000-0000-000000000001', 24.0,  3.60,  20.40, 'MAD', 'SUCCEEDED', 'CARD',       'pi_stripe_008', 'ch_stripe_008', 0, now()-interval'2 hours',      now()-interval'2 hours'),
(9,  9,  '00000000-0000-0000-0000-000000000010', 90.0,  13.50, 76.50, 'MAD', 'SUCCEEDED', 'GOOGLE_PAY', 'pi_stripe_009', 'ch_stripe_009', 0, now()-interval'1 day',        now()-interval'1 day'),
(10, 10, '00000000-0000-0000-0000-000000000005', 15.0,  2.25,  12.75, 'MAD', 'SUCCEEDED', 'APPLE_PAY',  'pi_stripe_010', 'ch_stripe_010', 0, now()-interval'2 hours',      now()-interval'2 hours'),
(11, 11, '00000000-0000-0000-0000-000000000006', 8.0,   1.20,  6.80,  'MAD', 'PENDING',   'CARD',       'pi_stripe_011', NULL,            0, now()-interval'30 minutes',   now()-interval'30 minutes');

SELECT setval('payments_id_seq', 11);


-- ========================
-- SEED: REVIEWS
-- ========================

INSERT INTO reviews (id, reservation_id, reviewer_id, spot_id, rating, comment, owner_reply, owner_replied_at, is_visible, created_at) VALUES
(1, 1, '00000000-0000-0000-0000-000000000001', 1, 5,
 'Excellent spot! Very clean, well-lit, and easy to find. The covered area is a huge plus in summer.',
 'Thank you Youssef! We look forward to seeing you again.', now()-interval'58 days', true, now()-interval'59 days'),

(2, 2, '00000000-0000-0000-0000-000000000002', 5, 4,
 'Good location near the Medina. A bit tight for parking, but the attendant was very helpful.',
 NULL, NULL, true, now()-interval'44 days'),

(3, 3, '00000000-0000-0000-0000-000000000001', 3, 5,
 'The EV charging made all the difference. Smooth experience from start to finish.',
 'So glad you enjoyed it! We recently upgraded the chargers.', now()-interval'28 days', true, now()-interval'29 days'),

(4, 4, '00000000-0000-0000-0000-000000000010', 8, 5,
 'Worth every dirham. The valet was professional, car was returned spotless.',
 NULL, NULL, true, now()-interval'19 days'),

(5, 5, '00000000-0000-0000-0000-000000000005', 2, 4,
 'Solid option in Gueliz. Good security. Would like better signage at the entrance though.',
 'Noted – we are updating the signs this month!', now()-interval'13 days', true, now()-interval'14 days'),

(6, 6, '00000000-0000-0000-0000-000000000008', 6, 4,
 'Nice private garage, felt very secure. The rolling shutter is a great touch.',
 NULL, NULL, true, now()-interval'9 days');

SELECT setval('reviews_id_seq', 6);


-- ========================
-- SEED: NOTIFICATIONS
-- ========================

INSERT INTO notifications (user_id, type, title, content, reference_id, reference_type, is_read, channel, sent_at, created_at) VALUES
('00000000-0000-0000-0000-000000000001', 'RESERVATION_CONFIRMED', 'Booking Confirmed',       'Your reservation at Covered Spot A1 has been confirmed for tomorrow.',    8,    'reservation', false, 'PUSH',   now()-interval'2 hours',    now()-interval'2 hours'),
('00000000-0000-0000-0000-000000000001', 'PAYMENT_SUCCESS',       'Payment Received',         'Payment of 24.00 MAD for reservation #8 was successful.',                8,    'reservation', true,  'EMAIL',  now()-interval'2 hours',    now()-interval'2 hours'),
('00000000-0000-0000-0000-000000000002', 'RESERVATION_CANCELLED', 'Reservation Cancelled',   'Your reservation #7 was cancelled. A refund of 16.00 MAD is on its way.', 7,   'reservation', true,  'PUSH',   now()-interval'7 days',     now()-interval'7 days'),
('00000000-0000-0000-0000-000000000003', 'REVIEW_RECEIVED',       'New Review on Your Spot',  'Youssef left a 5-star review on Covered Spot A1.',                       1,    'review',      false, 'IN_APP', now()-interval'59 days',    now()-interval'59 days'),
('00000000-0000-0000-0000-000000000005', 'PAYMENT_SUCCESS',       'Payment Received',         'Payment of 35.00 MAD for reservation #5 was successful.',                5,    'reservation', true,  'EMAIL',  now()-interval'16 days',    now()-interval'16 days'),
('00000000-0000-0000-0000-000000000010', 'RESERVATION_CONFIRMED', 'Booking Confirmed',        'Your EV bay at Hivernage is confirmed for the day after tomorrow.',       9,   'reservation', false, 'PUSH',   now()-interval'1 day',      now()-interval'1 day'),
('00000000-0000-0000-0000-000000000006', 'ACCOUNT_VERIFIED',      'Identity Verified',        'Your account identity is under review. We will notify you shortly.',     NULL, NULL,          false, 'EMAIL',  now()-interval'9 days',     now()-interval'9 days'),
('00000000-0000-0000-0000-000000000005', 'EXPIRY_REMINDER',       'Parking Expiring Soon',    'Your active parking at Bab Doukkala expires in 2 hours.',                10,   'reservation', false, 'PUSH',   now()-interval'30 minutes', now()-interval'30 minutes');


-- ========================
-- SEED: WISHLISTS
-- ========================

INSERT INTO wishlists (user_id, spot_id, added_at) VALUES
('00000000-0000-0000-0000-000000000001', 3, now()-interval'25 days'),
('00000000-0000-0000-0000-000000000001', 8, now()-interval'10 days'),
('00000000-0000-0000-0000-000000000002', 1, now()-interval'40 days'),
('00000000-0000-0000-0000-000000000005', 3, now()-interval'12 days'),
('00000000-0000-0000-0000-000000000010', 1, now()-interval'5 days'),
('00000000-0000-0000-0000-000000000010', 8, now()-interval'3 days'),
('00000000-0000-0000-0000-000000000008', 6, now()-interval'8 days');


-- ========================
-- SEED: REPORTS
-- ========================

INSERT INTO reports (reporter_id, target_id, target_type, reason, description, status, resolved_by, resolution, created_at, resolved_at) VALUES
('00000000-0000-0000-0000-000000000002', 7,  'PARKING_SPOT', 'WRONG_LOCATION',
 'The pin on the map is off by about 200 meters from the actual spot location.',
 'RESOLVED', '00000000-0000-0000-0000-000000000011',
 'Location coordinates updated by admin after field verification.',
 now()-interval'50 days', now()-interval'48 days'),

('00000000-0000-0000-0000-000000000005', 12, 'USER', 'FRAUD',
 'This user attempted to use a fake access code for my reserved spot.',
 'RESOLVED', '00000000-0000-0000-0000-000000000011',
 'User account suspended pending investigation.',
 now()-interval'22 days', now()-interval'20 days'),

('00000000-0000-0000-0000-000000000010', 6,  'REVIEW', 'SPAM',
 'This review appears to be fake — the same text was posted multiple times by similar accounts.',
 'PENDING', NULL, NULL,
 now()-interval'3 days', NULL);