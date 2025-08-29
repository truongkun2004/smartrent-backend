--drop database SmartRent

CREATE DATABASE SmartRent;
GO

USE SmartRent;
GO

-- Hosts
CREATE TABLE Hosts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    gender NVARCHAR(10),
    dob DATE,
    address NVARCHAR(255),
    phone NVARCHAR(20),
    email NVARCHAR(255),
    password NVARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),
    firebase_id NVARCHAR(255),
    balance DECIMAL(18,0) DEFAULT 0
);

-- Users
CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(255),
    password NVARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    firebase_id NVARCHAR(255),
);

-- Amenities
CREATE TABLE Amenities (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL
);

-- PropertyTypes
CREATE TABLE PropertyTypes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    has_details BIT DEFAULT 0,
    description NVARCHAR(500),
    price_multiplier DECIMAL(5,2) DEFAULT 1.0   -- hệ số giá dịch vụ
);

-- Properties
CREATE TABLE Properties (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(200) NOT NULL,
    host_id INT NOT NULL,
    type_id INT,
    price DECIMAL(18,0) NOT NULL,
    area DECIMAL(10,2),
    rooms INT,
    address NVARCHAR(300),
    description NVARCHAR(MAX),
    contact_info NVARCHAR(200),
    images NVARCHAR(MAX),
    is_available BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    is_deleted BIT DEFAULT 0,
    deleted_at DATETIME NULL,
    approval_status INT DEFAULT 0,
    FOREIGN KEY (host_id) REFERENCES Hosts(id) ON DELETE CASCADE,
    FOREIGN KEY (type_id) REFERENCES PropertyTypes(id) ON DELETE SET NULL
);

-- PropertyAmenities
CREATE TABLE PropertyAmenities (
    id INT IDENTITY(1,1) PRIMARY KEY,
    property_id INT NOT NULL,
    amenity_id INT NOT NULL,
    FOREIGN KEY (property_id) REFERENCES Properties(id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES Amenities(id) ON DELETE CASCADE
);

-- PropertyRooms
CREATE TABLE PropertyRooms (
    id INT IDENTITY(1,1) PRIMARY KEY,
    property_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    images NVARCHAR(MAX),
    description NVARCHAR(500),
    is_available BIT DEFAULT 1,
    FOREIGN KEY (property_id) REFERENCES Properties(id) ON DELETE CASCADE
);

-- RoomDetails
CREATE TABLE RoomAmenities (
    room_id INT NOT NULL,
    amenity_id INT NOT NULL,
    PRIMARY KEY (room_id, amenity_id),
    FOREIGN KEY (room_id) REFERENCES PropertyRooms(id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES Amenities(id) ON DELETE CASCADE
);

-- PropertyReviews
CREATE TABLE PropertyReviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    property_id INT NOT NULL,
    user_id INT NOT NULL,
    rating DECIMAL(3,1),
    created_at DATETIME DEFAULT GETDATE(),
    status BIT DEFAULT 1,
    comment NVARCHAR(500),
    FOREIGN KEY (property_id) REFERENCES Properties(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- UserFavorites
CREATE TABLE UserFavorites (
    id INT IDENTITY(1,1) PRIMARY KEY,
    property_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (property_id) REFERENCES Properties(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- PostingServices
CREATE TABLE PostingServices (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    cost DECIMAL(18,0) NOT NULL,
    duration INT NOT NULL
);

-- Contracts
CREATE TABLE Contracts (
    id INT IDENTITY(1,1) PRIMARY KEY,
    property_id INT NOT NULL,
    price_multiplier DECIMAL(5,2) DEFAULT 1.0,
    service_id INT NOT NULL,
    cost DECIMAL(18,0) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    duration INT,
    start_date DATE,
    end_date DATE,
    host_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    status INT DEFAULT 0,
    FOREIGN KEY (property_id) REFERENCES Properties(id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES PostingServices(id) ON DELETE CASCADE,
    FOREIGN KEY (host_id) REFERENCES Hosts(id)
);

-- Transactions
CREATE TABLE Transactions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    host_id INT NOT NULL,
    type NVARCHAR(20) CHECK (type IN ('deposit','withdraw')),
    amount DECIMAL(18,0) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    contract_id INT,
    FOREIGN KEY (host_id) REFERENCES Hosts(id),
    FOREIGN KEY (contract_id) REFERENCES Contracts(id)
);

GO

CREATE OR ALTER VIEW ViewPublishedProperties AS
SELECT 
    p.id,
    p.name,
    p.type_id,
    pt.name AS type_name,
    p.price,
    p.area,
    p.rooms,
    PARSENAME(REPLACE(p.address, '/', '.'), 4) AS province,
    PARSENAME(REPLACE(p.address, '/', '.'), 3) AS district,
    PARSENAME(REPLACE(p.address, '/', '.'), 2) AS ward,
    PARSENAME(REPLACE(p.address, '/', '.'), 1) AS specific_address,
    p.is_available,
    (
        SELECT 
            pa.amenity_id,
            a.name
        FROM PropertyAmenities pa
        JOIN Amenities a ON pa.amenity_id = a.id
        WHERE pa.property_id = p.id
        FOR JSON PATH
    ) AS amenities
FROM Properties p
JOIN PropertyTypes pt ON p.type_id = pt.id
WHERE p.approval_status = 1
  AND EXISTS (
      SELECT 1 
      FROM Contracts c
      WHERE c.property_id = p.id
        AND c.end_date > GETDATE()
  );
GO

-- INSERT DATA
-- Amenities sample data
INSERT INTO Amenities (name) VALUES
(N'Wi-Fi'),
(N'Máy lạnh'),
(N'Máy giặt'),
(N'Tủ lạnh'),
(N'Bãi đậu xe'),
(N'TV'),
(N'Giường'),
(N'Bàn ghế'),
(N'Camera an ninh'),
(N'Bảo vệ 24/7');

-- PropertyTypes sample data
INSERT INTO PropertyTypes (name, has_details, description, price_multiplier) VALUES
(N'Nhà trọ', 0, N'Phòng trọ giá rẻ cho sinh viên', 1.0),
(N'Nhà nguyên căn', 0, N'Nhà cho thuê nguyên căn', 1.2),
(N'Ký túc xá', 1, N'Phòng trọ giá rẻ cho sinh viên', 0.8),
(N'Chung cư', 1, N'Chung cư mini có nhiều phòng nhỏ', 1.5);

-- PostingServices sample data
INSERT INTO PostingServices (name, cost, duration) VALUES
(N'Gói ngày', 10000, 1),
(N'Gói tuần', 50000, 7),
(N'Gói tháng', 250000, 30),
(N'Gói năm', 3000000, 365);

select * from ViewPublishedProperties

select * from Hosts
select * from Contracts
select * from Users
select * from PropertyReviews
select * from Properties
select * from PropertyAmenities
select * from PropertyRooms
select * from RoomAmenities
--exec GetHostProperties 1