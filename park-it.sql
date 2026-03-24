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
  'DISPUTE_UPDATE'
);

CREATE TYPE notification_channel AS ENUM ('PUSH', 'EMAIL', 'IN_APP');

CREATE TYPE report_target_type AS ENUM ('USER', 'PARKING_SPOT', 'REVIEW');

CREATE TYPE report_reason AS ENUM ('FAKE_LISTING', 'SPAM', 'INAPPROPRIATE', 'FRAUD', 'WRONG_LOCATION');

CREATE TYPE report_status AS ENUM ('PENDING', 'RESOLVED', 'DISMISSED');


-- ========================
-- USERS
-- ========================

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,

  email VARCHAR UNIQUE,
  phone VARCHAR UNIQUE,

  password_hash VARCHAR,

  profile_photo VARCHAR,

  role user_role NOT NULL DEFAULT 'DRIVER',

  verification_status verification_status NOT NULL DEFAULT 'UNVERIFIED',

  identity_doc VARCHAR,

  is_suspended BOOLEAN NOT NULL DEFAULT false,
  suspension_at TIMESTAMP,
  suspension_end TIMESTAMP,

  is_banned BOOLEAN NOT NULL DEFAULT false,

  average_rating FLOAT NOT NULL DEFAULT 0,
  total_reviews INT NOT NULL DEFAULT 0,

  fcm_token VARCHAR,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  last_login_at TIMESTAMP
);


-- ========================
-- SOCIAL AUTHENTICATION
-- ========================

CREATE TABLE user_auth_providers (
  id SERIAL PRIMARY KEY,

  user_id UUID NOT NULL REFERENCES users(id),

  provider VARCHAR NOT NULL,           -- GOOGLE / FACEBOOK / APPLE
  provider_user_id VARCHAR NOT NULL,

  created_at TIMESTAMP DEFAULT now(),

  UNIQUE(provider, provider_user_id)
);


-- ========================
-- VEHICLES
-- ========================

CREATE TABLE vehicles (
  id SERIAL PRIMARY KEY,

  owner_id UUID NOT NULL REFERENCES users(id),

  plate_number VARCHAR UNIQUE NOT NULL,

  type vehicle_type NOT NULL,

  brand VARCHAR NOT NULL,
  model VARCHAR NOT NULL,
  color VARCHAR NOT NULL,

  is_default BOOLEAN NOT NULL DEFAULT false,

  created_at TIMESTAMP NOT NULL DEFAULT now()
);


-- ========================
-- PARKING LOTS
-- ========================

CREATE TABLE parking_lots (
  id SERIAL PRIMARY KEY,

  owner_id UUID NOT NULL REFERENCES users(id),

  name VARCHAR NOT NULL,
  description TEXT,

  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  altitude FLOAT,

  street VARCHAR NOT NULL,
  city VARCHAR NOT NULL,
  country VARCHAR NOT NULL,
  postal_code VARCHAR NOT NULL,

  photos TEXT[],

  amenities amenity[],

  total_spots INT,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


-- ========================
-- PARKING SPOTS
-- ========================

CREATE TABLE parking_spots (
  id SERIAL PRIMARY KEY,

  owner_id UUID NOT NULL REFERENCES users(id),

  lot_id INT REFERENCES parking_lots(id),

  title VARCHAR NOT NULL,
  description TEXT,

  latitude FLOAT,
  longitude FLOAT,
  altitude FLOAT,

  street VARCHAR,
  city VARCHAR,
  country VARCHAR,
  postal_code VARCHAR,

  photos TEXT[],

  price_per_hour FLOAT NOT NULL,
  price_per_day FLOAT,

  spot_type spot_type NOT NULL,

  vehicle_types vehicle_type[],

  amenities amenity[],

  status spot_status NOT NULL DEFAULT 'AVAILABLE',

  average_rating FLOAT NOT NULL DEFAULT 0,
  total_reviews INT NOT NULL DEFAULT 0,

  total_bookings INT NOT NULL DEFAULT 0,

  is_dynamic_pricing BOOLEAN NOT NULL DEFAULT false,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


-- ========================
-- RESERVATIONS
-- ========================

CREATE TABLE reservations (
  id SERIAL PRIMARY KEY,

  driver_id UUID NOT NULL REFERENCES users(id),

  spot_id INT NOT NULL REFERENCES parking_spots(id),

  vehicle_id INT NOT NULL REFERENCES vehicles(id),

  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,

  status reservation_status NOT NULL DEFAULT 'PENDING',

  total_price FLOAT NOT NULL,

  platform_fee FLOAT NOT NULL,

  lock_expires_at TIMESTAMP,

  cancellation_reason TEXT,

  access_code VARCHAR,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


-- ========================
-- PAYMENTS
-- ========================

CREATE TABLE payments (
  id SERIAL PRIMARY KEY,

  reservation_id INT UNIQUE NOT NULL REFERENCES reservations(id),

  payer_id UUID NOT NULL REFERENCES users(id),

  amount FLOAT NOT NULL,

  platform_fee FLOAT NOT NULL,

  owner_payout FLOAT NOT NULL,

  currency VARCHAR NOT NULL DEFAULT 'MAD',

  status payment_status NOT NULL DEFAULT 'PENDING',

  method payment_method NOT NULL,

  stripe_payment_intent_id VARCHAR,
  stripe_charge_id VARCHAR,

  refund_id VARCHAR,
  refund_amount FLOAT,

  retry_count INT NOT NULL DEFAULT 0,

  invoice_url VARCHAR,

  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);


-- ========================
-- REVIEWS
-- ========================

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,

  reservation_id INT UNIQUE NOT NULL REFERENCES reservations(id),

  reviewer_id UUID NOT NULL REFERENCES users(id),

  spot_id INT NOT NULL REFERENCES parking_spots(id),

  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),

  comment TEXT,

  owner_reply TEXT,
  owner_replied_at TIMESTAMP,

  is_visible BOOLEAN NOT NULL DEFAULT true,

  created_at TIMESTAMP NOT NULL DEFAULT now()
);


-- ========================
-- NOTIFICATIONS
-- ========================

CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,

  user_id UUID NOT NULL REFERENCES users(id),

  type notification_type NOT NULL,

  title VARCHAR NOT NULL,

  content TEXT NOT NULL,

  reference_id INT,
  reference_type VARCHAR,

  is_read BOOLEAN NOT NULL DEFAULT false,

  channel notification_channel NOT NULL,

  sent_at TIMESTAMP,

  created_at TIMESTAMP NOT NULL DEFAULT now()
);


-- ========================
-- REPORTS
-- ========================

CREATE TABLE reports (
  id SERIAL PRIMARY KEY,

  reporter_id UUID NOT NULL REFERENCES users(id),

  target_id INT NOT NULL,

  target_type report_target_type NOT NULL,

  reason report_reason NOT NULL,

  description TEXT,

  status report_status NOT NULL DEFAULT 'PENDING',

  resolved_by UUID REFERENCES users(id),

  resolution TEXT,

  created_at TIMESTAMP NOT NULL DEFAULT now(),

  resolved_at TIMESTAMP
);


-- ========================
-- WISHLISTS
-- ========================

CREATE TABLE wishlists (
  id SERIAL PRIMARY KEY,

  user_id UUID NOT NULL REFERENCES users(id),

  spot_id INT NOT NULL REFERENCES parking_spots(id),

  added_at TIMESTAMP NOT NULL DEFAULT now(),

  UNIQUE (user_id, spot_id)
);


-- ========================
-- AVAILABILITIES
-- ========================

CREATE TABLE availabilities (
  id SERIAL PRIMARY KEY,

  spot_id INT NOT NULL REFERENCES parking_spots(id),

  day_of_week INT CHECK (day_of_week BETWEEN 0 AND 6),

  specific_date DATE,

  open_time TIME NOT NULL,
  close_time TIME NOT NULL,

  is_blocked BOOLEAN NOT NULL DEFAULT false
);


-- ========================
-- DYNAMIC PRICING
-- ========================

CREATE TABLE dynamic_pricing_rules (
  id SERIAL PRIMARY KEY,

  spot_id INT NOT NULL REFERENCES parking_spots(id),

  three_hours DOUBLE PRECISION,
  six_hours DOUBLE PRECISION,
  twelve_hours DOUBLE PRECISION,

  is_active BOOLEAN NOT NULL DEFAULT true
);