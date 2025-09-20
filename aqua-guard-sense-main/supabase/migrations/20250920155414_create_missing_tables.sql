-- Create missing tables for AquaGuard Sense
-- This migration creates the notifications and tank_configs tables

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  severity VARCHAR(20) DEFAULT 'medium',
  esp32_id VARCHAR(100),
  read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  persistent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create tank_configs table
CREATE TABLE IF NOT EXISTS tank_configs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tank_id VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  capacity_liters INTEGER NOT NULL,
  height_cm INTEGER NOT NULL,
  sensor_offset_cm INTEGER DEFAULT 0,
  critical_level_percentage DECIMAL(5,2) DEFAULT 10.0,
  warning_level_percentage DECIMAL(5,2) DEFAULT 25.0,
  auto_mode_enabled BOOLEAN DEFAULT true,
  manual_override BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies for notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read notifications
CREATE POLICY "Users can view notifications" ON notifications
  FOR SELECT USING (auth.role() = 'authenticated');

-- Allow authenticated users to insert notifications
CREATE POLICY "Users can insert notifications" ON notifications
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow authenticated users to update notifications
CREATE POLICY "Users can update notifications" ON notifications
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Add RLS policies for tank_configs
ALTER TABLE tank_configs ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read tank configs
CREATE POLICY "Users can view tank configs" ON tank_configs
  FOR SELECT USING (auth.role() = 'authenticated');

-- Allow authenticated users to insert tank configs
CREATE POLICY "Users can insert tank configs" ON tank_configs
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow authenticated users to update tank configs
CREATE POLICY "Users can update tank configs" ON tank_configs
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Insert default tank configurations
INSERT INTO tank_configs (tank_id, name, capacity_liters, height_cm, sensor_offset_cm, critical_level_percentage, warning_level_percentage, auto_mode_enabled, manual_override)
VALUES
  ('top_tank', 'Top Tank', 500, 100, 5, 10.0, 25.0, true, false),
  ('sump_tank', 'Sump Tank', 1000, 120, 5, 15.0, 30.0, true, false)
ON CONFLICT (tank_id) DO NOTHING;