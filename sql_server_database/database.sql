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
    description NVARCHAR(500)
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
    rating INT CHECK (rating BETWEEN 1 AND 5),
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
    service_id INT NOT NULL,
    cost DECIMAL(18,0) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    host_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
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
INSERT INTO PropertyTypes (name, has_details, description) VALUES
(N'Nhà trọ', 0, N'Phòng trọ giá rẻ cho sinh viên'),
(N'Nhà nguyên căn', 0, N'Nhà cho thuê nguyên căn'),
(N'Ký túc xá', 1, N'Phòng trọ giá rẻ cho sinh viên'),
(N'Chung cư', 1, N'Chung cư mini có nhiều phòng nhỏ');

select * from Hosts
select * from Users
select * from Properties
select * from PropertyAmenities
select * from PropertyRooms
select * from RoomAmenities
exec GetHostProperties 1