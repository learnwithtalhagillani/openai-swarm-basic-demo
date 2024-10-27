
-- Drop tables if they exist
DROP TABLE IF EXISTS donations;
DROP TABLE IF EXISTS donors;
DROP TABLE IF EXISTS campaigns;
DROP TABLE IF EXISTS payment_methods;

-- Create donors table
CREATE TABLE donors (
    donor_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    donation_frequency TEXT CHECK(donation_frequency IN ('one_time', 'monthly', 'quarterly', 'annually')),
    total_lifetime_donations DECIMAL(10,2) DEFAULT 0.00
);

-- Create campaigns table
CREATE TABLE campaigns (
    campaign_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    goal_amount DECIMAL(10,2),
    current_amount DECIMAL(10,2) DEFAULT 0.00,
    status TEXT CHECK(status IN ('active', 'completed', 'cancelled')) DEFAULT 'active',
    category TEXT
);

-- Create payment_methods table
CREATE TABLE payment_methods (
    payment_method_id INTEGER PRIMARY KEY,
    donor_id INTEGER,
    payment_type TEXT CHECK(payment_type IN ('credit_card', 'debit_card', 'bank_transfer', 'paypal', 'crypto')),
    last_four TEXT,
    expiry_date TEXT,
    is_default BOOLEAN DEFAULT 0,
    FOREIGN KEY (donor_id) REFERENCES donors(donor_id)
);

-- Create donations table
CREATE TABLE donations (
    donation_id INTEGER PRIMARY KEY,
    donor_id INTEGER,
    campaign_id INTEGER,
    payment_method_id INTEGER,
    amount DECIMAL(10,2) NOT NULL,
    donation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT CHECK(status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
    is_anonymous BOOLEAN DEFAULT 0,
    message TEXT,
    FOREIGN KEY (donor_id) REFERENCES donors(donor_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(payment_method_id)
);

-- Create views for analysis
CREATE VIEW donor_summary AS
SELECT 
    d.donor_id,
    d.first_name || ' ' || d.last_name as full_name,
    d.email,
    d.donation_frequency,
    COUNT(don.donation_id) as total_donations,
    SUM(don.amount) as total_amount,
    AVG(don.amount) as average_donation,
    MAX(don.donation_date) as last_donation_date
FROM donors d
LEFT JOIN donations don ON d.donor_id = don.donor_id
GROUP BY d.donor_id;

CREATE VIEW campaign_summary AS
SELECT 
    c.campaign_id,
    c.name,
    c.category,
    c.goal_amount,
    SUM(d.amount) as total_raised,
    COUNT(DISTINCT d.donor_id) as unique_donors,
    ROUND((SUM(d.amount) / c.goal_amount) * 100, 2) as completion_percentage
FROM campaigns c
LEFT JOIN donations d ON c.campaign_id = d.campaign_id
GROUP BY c.campaign_id;