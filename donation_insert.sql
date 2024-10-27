


-- Insert mock data for donors
INSERT INTO donors (first_name, last_name, email, phone, donation_frequency, total_lifetime_donations) VALUES
('John', 'Doe', 'john.doe@email.com', '555-0101', 'monthly', 1200.00),
('Jane', 'Smith', 'jane.smith@email.com', '555-0102', 'quarterly', 5000.00),
('Bob', 'Johnson', 'bob.j@email.com', '555-0103', 'one_time', 500.00),
('Alice', 'Williams', 'alice.w@email.com', '555-0104', 'annually', 2000.00),
('Charlie', 'Brown', 'charlie.b@email.com', '555-0105', 'monthly', 800.00);

-- Insert mock data for campaigns
INSERT INTO campaigns (name, description, start_date, end_date, goal_amount, current_amount, status, category) VALUES
('COVID-19 Relief', 'Support healthcare workers', '2023-01-01', '2024-12-31', 100000.00, 75000.00, 'active', 'Healthcare'),
('Education Fund', 'Scholarships for students', '2023-06-01', '2024-05-31', 50000.00, 30000.00, 'active', 'Education'),
('Environmental Initiative', 'Plant trees', '2023-03-15', '2024-03-14', 25000.00, 15000.00, 'active', 'Environment'),
('Animal Shelter', 'Support local shelters', '2023-09-01', '2024-08-31', 30000.00, 20000.00, 'active', 'Animal Welfare'),
('Food Bank', 'Feed the hungry', '2023-11-01', '2024-10-31', 40000.00, 25000.00, 'active', 'Food Security');

-- Insert mock data for payment methods
INSERT INTO payment_methods (donor_id, payment_type, last_four, expiry_date, is_default) VALUES
(1, 'credit_card', '4532', '12/25', 1),
(2, 'paypal', NULL, NULL, 1),
(3, 'bank_transfer', '9876', NULL, 1),
(4, 'credit_card', '1234', '03/26', 1),
(5, 'crypto', NULL, NULL, 1);

-- Insert mock data for donations
INSERT INTO donations (donor_id, campaign_id, payment_method_id, amount, donation_date, status, is_anonymous, message) VALUES
(1, 1, 1, 100.00, '2023-12-01 10:00:00', 'completed', 0, 'Keep up the great work!'),
(2, 1, 2, 500.00, '2023-12-02 11:30:00', 'completed', 1, NULL),
(3, 2, 3, 250.00, '2023-12-03 14:15:00', 'completed', 0, 'For a better future'),
(4, 3, 4, 1000.00, '2023-12-04 09:45:00', 'completed', 0, 'Save our planet'),
(5, 4, 5, 150.00, '2023-12-05 16:20:00', 'completed', 0, 'Help the animals'),
(1, 2, 1, 75.00, '2023-12-06 13:10:00', 'completed', 0, NULL),
(2, 3, 2, 300.00, '2023-12-07 15:30:00', 'completed', 0, 'Environmental support'),
(3, 5, 3, 200.00, '2023-12-08 11:45:00', 'completed', 0, 'Feed the hungry'),
(4, 4, 4, 450.00, '2023-12-09 10:25:00', 'completed', 1, NULL),
(5, 1, 5, 125.00, '2023-12-10 14:50:00', 'completed', 0, 'For healthcare heroes');
