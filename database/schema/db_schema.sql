-- Tạo database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'BTLSQL-ThaiDoHocTapSv')
BEGIN
    CREATE DATABASE BTLSQL-ThaiDoHocTapSv;
END
GO

USE BTLSQL-ThaiDoHocTapSv;
GO

-- Bảng Khoa (Departments)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Departments')
BEGIN
    CREATE TABLE Departments (
        department_id VARCHAR(10) PRIMARY KEY,
        department_name NVARCHAR(100) NOT NULL,
        dean_name NVARCHAR(100),
        description NVARCHAR(MAX),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- Bảng Giảng viên (Teachers)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Teachers')
BEGIN
    CREATE TABLE Teachers (
        teacher_id VARCHAR(10) PRIMARY KEY,
        full_name NVARCHAR(100) NOT NULL,
        gender NVARCHAR(10) NOT NULL CHECK (gender IN (N'Nam', N'Nữ', N'Khác')),
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(15),
        department_id VARCHAR(10) NOT NULL,
        position NVARCHAR(50),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (department_id) REFERENCES Departments(department_id)
    );
END
GO

-- Bảng Ngành học (Majors)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Majors')
BEGIN
    CREATE TABLE Majors (
        major_id VARCHAR(10) PRIMARY KEY,
        major_name NVARCHAR(100) NOT NULL,
        department_id VARCHAR(10) NOT NULL,
        description NVARCHAR(MAX),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (department_id) REFERENCES Departments(department_id)
    );
END
GO

-- Bảng Lớp (Classes)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Classes')
BEGIN
    CREATE TABLE Classes (
        class_id VARCHAR(10) PRIMARY KEY,
        class_name NVARCHAR(100) NOT NULL,
        department_id VARCHAR(10) NOT NULL,
        major_id VARCHAR(10) NOT NULL,
        homeroom_teacher_id VARCHAR(10),
        year_started INT NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (department_id) REFERENCES Departments(department_id),
        FOREIGN KEY (major_id) REFERENCES Majors(major_id),
        FOREIGN KEY (homeroom_teacher_id) REFERENCES Teachers(teacher_id)
    );
END
GO

-- Bảng Sinh viên (Students)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Students')
BEGIN
    CREATE TABLE Students (
        student_id VARCHAR(10) PRIMARY KEY,
        full_name NVARCHAR(100) NOT NULL,
        dob DATE NOT NULL,
        gender NVARCHAR(10) NOT NULL CHECK (gender IN (N'Nam', N'Nữ', N'Khác')),
        email VARCHAR(100) UNIQUE NOT NULL,
        phone VARCHAR(15),
        address NVARCHAR(200),
        class_id VARCHAR(10) NOT NULL,
        major_id VARCHAR(10) NOT NULL,
        year_enrolled INT NOT NULL,
        status NVARCHAR(20) NOT NULL DEFAULT N'Đang học' CHECK (status IN (N'Đang học', N'Bảo lưu', N'Thôi học', N'Tốt nghiệp')),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (class_id) REFERENCES Classes(class_id),
        FOREIGN KEY (major_id) REFERENCES Majors(major_id)
    );
END
GO

-- Bảng Môn học (Subjects)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Subjects')
BEGIN
    CREATE TABLE Subjects (
        subject_id VARCHAR(10) PRIMARY KEY,
        subject_name NVARCHAR(100) NOT NULL,
        credits INT NOT NULL,
        department_id VARCHAR(10) NOT NULL,
        description NVARCHAR(MAX),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (department_id) REFERENCES Departments(department_id)
    );
END
GO

-- Bảng Lớp học phần (Course_Offerings)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Course_Offerings')
BEGIN
    CREATE TABLE Course_Offerings (
        offering_id VARCHAR(20) PRIMARY KEY,
        subject_id VARCHAR(10) NOT NULL,
        teacher_id VARCHAR(10) NOT NULL,
        semester VARCHAR(3) NOT NULL CHECK (semester IN ('1', '2', N'Hè')),
        academic_year VARCHAR(9) NOT NULL,
        max_students INT NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id),
        FOREIGN KEY (teacher_id) REFERENCES Teachers(teacher_id)
    );
END
GO

-- Bảng Đăng ký học phần (Course_Registration)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Course_Registration')
BEGIN
    CREATE TABLE Course_Registration (
        registration_id INT IDENTITY(1,1) PRIMARY KEY,
        student_id VARCHAR(10) NOT NULL,
        offering_id VARCHAR(20) NOT NULL,
        registration_date DATETIME NOT NULL,
        status NVARCHAR(20) NOT NULL CHECK (status IN (N'Đăng ký', N'Đang học', N'Hoàn thành', N'Đã hủy')),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT UQ_StudentOffering UNIQUE (student_id, offering_id),
        FOREIGN KEY (student_id) REFERENCES Students(student_id),
        FOREIGN KEY (offering_id) REFERENCES Course_Offerings(offering_id)
    );
END
GO

-- Bảng Buổi học (Class_Sessions)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Class_Sessions')
BEGIN
    CREATE TABLE Class_Sessions (
        session_id INT IDENTITY(1,1) PRIMARY KEY,
        offering_id VARCHAR(20) NOT NULL,
        session_date DATE NOT NULL,
        start_time TIME NOT NULL,
        end_time TIME NOT NULL,
        room VARCHAR(20) NOT NULL,
        topic NVARCHAR(200),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (offering_id) REFERENCES Course_Offerings(offering_id)
    );
END
GO

-- Bảng Điểm danh (Attendance)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Attendance')
BEGIN
    CREATE TABLE Attendance (
        attendance_id INT IDENTITY(1,1) PRIMARY KEY,
        student_id VARCHAR(10) NOT NULL,
        session_id INT NOT NULL,
        status NVARCHAR(20) NOT NULL CHECK (status IN (N'Có mặt', N'Vắng mặt', N'Đi muộn', N'Có phép')),
        time_recorded DATETIME NOT NULL,
        notes NVARCHAR(MAX),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT UQ_StudentSession UNIQUE (student_id, session_id),
        FOREIGN KEY (student_id) REFERENCES Students(student_id),
        FOREIGN KEY (session_id) REFERENCES Class_Sessions(session_id)
    );
END
GO

-- Bảng Thái độ học tập (Learning_Attitude)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Learning_Attitude')
BEGIN
    CREATE TABLE Learning_Attitude (
        assessment_id INT IDENTITY(1,1) PRIMARY KEY,
        student_id VARCHAR(10) NOT NULL,
        offering_id VARCHAR(20) NOT NULL,
        participation_rate DECIMAL(5,2),
        focus_level NVARCHAR(20) CHECK (focus_level IN (N'Kém', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc')),
        assignment_completion DECIMAL(5,2),
        discussion_participation INT,
        proactiveness NVARCHAR(20) CHECK (proactiveness IN (N'Thụ động', N'Trung bình', N'Chủ động')),
        teamwork NVARCHAR(20) CHECK (teamwork IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')),
        respectfulness NVARCHAR(20) CHECK (respectfulness IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')),
        notes NVARCHAR(MAX),
        assessor_id VARCHAR(10) NOT NULL,
        assessment_date DATETIME NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (student_id) REFERENCES Students(student_id),
        FOREIGN KEY (offering_id) REFERENCES Course_Offerings(offering_id),
        FOREIGN KEY (assessor_id) REFERENCES Teachers(teacher_id)
    );
END
GO

-- Bảng Vi phạm kỷ luật (Discipline_Issues)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Discipline_Issues')
BEGIN
    CREATE TABLE Discipline_Issues (
        issue_id INT IDENTITY(1,1) PRIMARY KEY,
        student_id VARCHAR(10) NOT NULL,
        issue_date DATE NOT NULL,
        violation_type NVARCHAR(100) NOT NULL,
        severity NVARCHAR(20) NOT NULL CHECK (severity IN (N'Nhẹ', N'Trung bình', N'Nghiêm trọng', N'Rất nghiêm trọng')),
        resolution NVARCHAR(200),
        reporter_id VARCHAR(10) NOT NULL,
        notes NVARCHAR(MAX),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (student_id) REFERENCES Students(student_id),
        FOREIGN KEY (reporter_id) REFERENCES Teachers(teacher_id)
    );
END
GO

-- Bảng Điểm (Grades)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Grades')
BEGIN
    CREATE TABLE Grades (
        grade_id INT IDENTITY(1,1) PRIMARY KEY,
        registration_id INT NOT NULL,
        midterm_score DECIMAL(4,2),
        final_score DECIMAL(4,2),
        total_score DECIMAL(4,2),
        grade_letter VARCHAR(2),
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT UQ_Registration UNIQUE (registration_id),
        FOREIGN KEY (registration_id) REFERENCES Course_Registration(registration_id)
    );
END
GO

-- Bảng Điểm rèn luyện (Conduct_Scores)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Conduct_Scores')
BEGIN
    CREATE TABLE Conduct_Scores (
        conduct_id INT IDENTITY(1,1) PRIMARY KEY,
        student_id VARCHAR(10) NOT NULL,
        semester VARCHAR(1) NOT NULL CHECK (semester IN ('1', '2')),
        academic_year VARCHAR(9) NOT NULL,
        self_score INT,
        class_score INT,
        faculty_score INT,
        final_score INT NOT NULL,
        classification NVARCHAR(20) NOT NULL CHECK (classification IN (N'Xuất sắc', N'Tốt', N'Khá', N'Trung bình', N'Yếu', N'Kém')),
        assessor_id VARCHAR(10) NOT NULL,
        assessment_date DATE NOT NULL,
        created_at DATETIME DEFAULT GETDATE(),
        updated_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT UQ_StudentSemesterYear UNIQUE (student_id, semester, academic_year),
        FOREIGN KEY (student_id) REFERENCES Students(student_id),
        FOREIGN KEY (assessor_id) REFERENCES Teachers(teacher_id)
    );
END
GO

-- Tạo trigger để cập nhật trường updated_at khi dữ liệu thay đổi
CREATE OR ALTER TRIGGER TR_Departments_Update ON Departments AFTER UPDATE AS
BEGIN
    UPDATE Departments SET updated_at = GETDATE() WHERE department_id IN (SELECT department_id FROM inserted);
END
GO

CREATE OR ALTER TRIGGER TR_Teachers_Update ON Teachers AFTER UPDATE AS
BEGIN
    UPDATE Teachers SET updated_at = GETDATE() WHERE teacher_id IN (SELECT teacher_id FROM inserted);
END
GO
-- Trigger for Majors
CREATE OR ALTER TRIGGER TR_Majors_Update 
ON Majors 
AFTER UPDATE 
AS
BEGIN
    UPDATE Majors 
    SET updated_at = GETDATE() 
    WHERE major_id IN (SELECT major_id FROM inserted);
END
GO

-- Trigger for Classes
CREATE OR ALTER TRIGGER TR_Classes_Update 
ON Classes 
AFTER UPDATE 
AS
BEGIN
    UPDATE Classes 
    SET updated_at = GETDATE() 
    WHERE class_id IN (SELECT class_id FROM inserted);
END
GO

-- Trigger for Students
CREATE OR ALTER TRIGGER TR_Students_Update 
ON Students 
AFTER UPDATE 
AS
BEGIN
    UPDATE Students 
    SET updated_at = GETDATE() 
    WHERE student_id IN (SELECT student_id FROM inserted);
END
GO

-- Trigger for Subjects
CREATE OR ALTER TRIGGER TR_Subjects_Update 
ON Subjects 
AFTER UPDATE 
AS
BEGIN
    UPDATE Subjects 
    SET updated_at = GETDATE() 
    WHERE subject_id IN (SELECT subject_id FROM inserted);
END
GO

-- Trigger for Course_Offerings
CREATE OR ALTER TRIGGER TR_Course_Offerings_Update 
ON Course_Offerings 
AFTER UPDATE 
AS
BEGIN
    UPDATE Course_Offerings 
    SET updated_at = GETDATE() 
    WHERE offering_id IN (SELECT offering_id FROM inserted);
END
GO

-- Trigger for Course_Registration
CREATE OR ALTER TRIGGER TR_Course_Registration_Update 
ON Course_Registration 
AFTER UPDATE 
AS
BEGIN
    UPDATE Course_Registration 
    SET updated_at = GETDATE() 
    WHERE registration_id IN (SELECT registration_id FROM inserted);
END
GO

-- Trigger for Class_Sessions
CREATE OR ALTER TRIGGER TR_Class_Sessions_Update 
ON Class_Sessions 
AFTER UPDATE 
AS
BEGIN
    UPDATE Class_Sessions 
    SET updated_at = GETDATE() 
    WHERE session_id IN (SELECT session_id FROM inserted);
END
GO

-- Trigger for Attendance
CREATE OR ALTER TRIGGER TR_Attendance_Update 
ON Attendance 
AFTER UPDATE 
AS
BEGIN
    UPDATE Attendance 
    SET updated_at = GETDATE() 
    WHERE attendance_id IN (SELECT attendance_id FROM inserted);
END
GO

-- Trigger for Learning_Attitude
CREATE OR ALTER TRIGGER TR_Learning_Attitude_Update 
ON Learning_Attitude 
AFTER UPDATE 
AS
BEGIN
    UPDATE Learning_Attitude 
    SET updated_at = GETDATE() 
    WHERE assessment_id IN (SELECT assessment_id FROM inserted);
END
GO

-- Trigger for Discipline_Issues
CREATE OR ALTER TRIGGER TR_Discipline_Issues_Update 
ON Discipline_Issues 
AFTER UPDATE 
AS
BEGIN
    UPDATE Discipline_Issues 
    SET updated_at = GETDATE() 
    WHERE issue_id IN (SELECT issue_id FROM inserted);
END
GO

-- Trigger for Grades
CREATE OR ALTER TRIGGER TR_Grades_Update 
ON Grades 
AFTER UPDATE 
AS
BEGIN
    UPDATE Grades 
    SET updated_at = GETDATE() 
    WHERE grade_id IN (SELECT grade_id FROM inserted);
END
GO

-- Trigger for Conduct_Scores
CREATE OR ALTER TRIGGER TR_Conduct_Scores_Update 
ON Conduct_Scores 
AFTER UPDATE 
AS
BEGIN
    UPDATE Conduct_Scores 
    SET updated_at = GETDATE() 
    WHERE conduct_id IN (SELECT conduct_id FROM inserted);
END
GO
-- Tương tự cho các bảng khác...
-- Thêm dữ liệu mẫu cho bảng Khoa (Departments)
INSERT INTO Departments (department_id, department_name, dean_name, description)
VALUES 
('CNTT', N'Công nghệ thông tin', N'TS. Nguyễn Văn A', N'Khoa Công nghệ thông tin'),
('KTXD', N'Kỹ thuật xây dựng', N'TS. Lê Thị B', N'Khoa Kỹ thuật xây dựng'),
('KTCK', N'Kỹ thuật cơ khí', N'PGS.TS. Trần Văn C', N'Khoa Kỹ thuật cơ khí'),
('KTOTO', N'Kỹ thuật ô tô', N'TS. Phạm Thị D', N'Khoa Kỹ thuật ô tô'),
('QTKD', N'Quản trị kinh doanh', N'PGS.TS. Hoàng Văn E', N'Khoa Quản trị kinh doanh');
GO

-- Thêm dữ liệu mẫu cho bảng Giảng viên (Teachers)
INSERT INTO Teachers (teacher_id, full_name, gender, email, phone, department_id, position)
VALUES 
('GV001', N'Nguyễn Văn A', N'Nam', 'nguyenvana@gtvt.edu.vn', '0901234567', 'CNTT', N'Trưởng khoa'),
('GV002', N'Lê Thị B', N'Nữ', 'lethib@gtvt.edu.vn', '0912345678', 'KTXD', N'Trưởng khoa'),
('GV003', N'Trần Văn C', N'Nam', 'tranvanc@gtvt.edu.vn', '0923456789', 'KTCK', N'Trưởng khoa'),
('GV004', N'Phạm Thị D', N'Nữ', 'phamthid@gtvt.edu.vn', '0934567890', 'KTOTO', N'Trưởng khoa'),
('GV005', N'Hoàng Văn E', N'Nam', 'hoangvane@gtvt.edu.vn', '0945678901', 'QTKD', N'Trưởng khoa'),
('GV006', N'Trịnh Thị F', N'Nữ', 'trinhthif@gtvt.edu.vn', '0956789012', 'CNTT', N'Giảng viên'),
('GV007', N'Lý Văn G', N'Nam', 'lyvang@gtvt.edu.vn', '0967890123', 'KTXD', N'Giảng viên'),
('GV008', N'Đặng Thị H', N'Nữ', 'dangthih@gtvt.edu.vn', '0978901234', 'KTCK', N'Giảng viên'),
('GV009', N'Vũ Văn I', N'Nam', 'vuvani@gtvt.edu.vn', '0989012345', 'KTOTO', N'Giảng viên'),
('GV010', N'Ngô Thị K', N'Nữ', 'ngothik@gtvt.edu.vn', '0990123456', 'QTKD', N'Giảng viên');
GO
-- Thêm dữ liệu mẫu cho bảng Ngành học (Majors)
INSERT INTO Majors (major_id, major_name, department_id, description)
VALUES 
('CNPM', N'Công nghệ phần mềm', 'CNTT', N'Ngành đào tạo về phát triển phần mềm'),
('KTPM', N'Kỹ thuật phần mềm', 'CNTT', N'Ngành đào tạo về kỹ thuật phần mềm'),
('XDDD', N'Xây dựng dân dụng', 'KTXD', N'Ngành đào tạo về xây dựng dân dụng và công nghiệp'),
('CNCK', N'Cơ khí chế tạo', 'KTCK', N'Ngành đào tạo về cơ khí chế tạo'),
('OTOKT', N'Kỹ thuật ô tô', 'KTOTO', N'Ngành đào tạo về kỹ thuật ô tô'),
('QTKD', N'Quản trị kinh doanh', 'QTKD', N'Ngành đào tạo về quản trị kinh doanh');
GO

-- Thêm dữ liệu mẫu cho bảng Lớp (Classes)
INSERT INTO Classes (class_id, class_name, department_id, major_id, homeroom_teacher_id, year_started)
VALUES 
('CNPM01', N'Công nghệ phần mềm K45', 'CNTT', 'CNPM', 'GV001', 2023),
('KTPM01', N'Kỹ thuật phần mềm K45', 'CNTT', 'KTPM', 'GV006', 2023),
('XDDD01', N'Xây dựng dân dụng K45', 'KTXD', 'XDDD', 'GV002', 2023),
('CNCK01', N'Cơ khí chế tạo K45', 'KTCK', 'CNCK', 'GV003', 2023),
('OTOKT01', N'Kỹ thuật ô tô K45', 'KTOTO', 'OTOKT', 'GV004', 2023),
('QTKD01', N'Quản trị kinh doanh K45', 'QTKD', 'QTKD', 'GV005', 2023);
GO

-- Thêm dữ liệu mẫu cho bảng Sinh viên (Students)
INSERT INTO Students (student_id, full_name, dob, gender, email, phone, address, class_id, major_id, year_enrolled, status)
VALUES 
('SV001', N'Nguyễn Văn Hùng', '2003-05-10', N'Nam', 'nguyenvanhung@sv.gtv.edu.vn', '0911111111', N'Hà Nội', 'CNPM01', 'CNPM', 2023, N'Đang học'),
('SV002', N'Trần Thị Mai', '2003-07-15', N'Nữ', 'tranthimai@sv.gtv.edu.vn', '0922222222', N'Hà Nội', 'CNPM01', 'CNPM', 2023, N'Đang học'),
('SV003', N'Lê Văn Nam', '2003-03-20', N'Nam', 'levannam@sv.gtv.edu.vn', '0933333333', N'TP.HCM', 'KTPM01', 'KTPM', 2023, N'Đang học'),
('SV004', N'Phạm Thị Lan', '2003-09-25', N'Nữ', 'phamthilan@sv.gtv.edu.vn', '0944444444', N'Đà Nẵng', 'XDDD01', 'XDDD', 2023, N'Đang học'),
('SV005', N'Hoàng Văn Tùng', '2003-11-30', N'Nam', 'hoangvantung@sv.gtv.edu.vn', '0955555555', N'Hà Nội', 'CNCK01', 'CNCK', 2023, N'Đang học'),
('SV006', N'Ngô Thị Hoa', '2003-01-12', N'Nữ', 'ngothihoa@sv.gtv.edu.vn', '0966666666', N'Hải Phòng', 'OTOKT01', 'OTOKT', 2023, N'Đang học'),
('SV007', N'Vũ Văn Long', '2003-06-18', N'Nam', 'vuvanlong@sv.gtv.edu.vn', '0977777777', N'Hà Nội', 'QTKD01', 'QTKD', 2023, N'Đang học');
GO

-- Thêm dữ liệu mẫu cho bảng Môn học (Subjects)
INSERT INTO Subjects (subject_id, subject_name, credits, department_id, description)
VALUES 
('TH01', N'Lập trình cơ bản', 3, 'CNTT', N'Môn học về lập trình cơ bản với C++'),
('TH02', N'Cấu trúc dữ liệu', 3, 'CNTT', N'Môn học về cấu trúc dữ liệu và giải thuật'),
('XD01', N'Kỹ thuật xây dựng', 3, 'KTXD', N'Môn học về kỹ thuật xây dựng cơ bản'),
('CK01', N'Cơ học kỹ thuật', 3, 'KTCK', N'Môn học về cơ học kỹ thuật'),
('OT01', N'Kỹ thuật ô tô cơ bản', 3, 'KTOTO', N'Môn học về kỹ thuật ô tô'),
('QT01', N'Quản trị học', 3, 'QTKD', N'Môn học về quản trị học cơ bản');
GO

-- Thêm dữ liệu mẫu cho bảng Lớp học phần (Course_Offerings)
INSERT INTO Course_Offerings (offering_id, subject_id, teacher_id, semester, academic_year, max_students)
VALUES 
('TH01_2024_1', 'TH01', 'GV006', '1', '2024-2025', 50),
('TH02_2024_1', 'TH02', 'GV006', '1', '2024-2025', 50),
('XD01_2024_1', 'XD01', 'GV007', '1', '2024-2025', 50),
('CK01_2024_1', 'CK01', 'GV008', '1', '2024-2025', 50),
('OT01_2024_1', 'OT01', 'GV009', '1', '2024-2025', 50),
('QT01_2024_1', 'QT01', 'GV010', '1', '2024-2025', 50);
GO

-- Thêm dữ liệu mẫu cho bảng Đăng ký học phần (Course_Registration)
INSERT INTO Course_Registration (student_id, offering_id, registration_date, status)
VALUES 
('SV001', 'TH01_2024_1', '2024-08-01', N'Đang học'),
('SV002', 'TH01_2024_1', '2024-08-01', N'Đang học'),
('SV003', 'TH02_2024_1', '2024-08-01', N'Đang học'),
('SV004', 'XD01_2024_1', '2024-08-01', N'Đang học'),
('SV005', 'CK01_2024_1', '2024-08-01', N'Đang học'),
('SV006', 'OT01_2024_1', '2024-08-01', N'Đang học'),
('SV007', 'QT01_2024_1', '2024-08-01', N'Đang học');
GO

-- Thêm dữ liệu mẫu cho bảng Buổi học (Class_Sessions)
INSERT INTO Class_Sessions (offering_id, session_date, start_time, end_time, room, topic)
VALUES 
('TH01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'A101', N'Giới thiệu lập trình C++'),
('TH02_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'A102', N'Mảng và con trỏ'),
('XD01_2024_1', '2024-09-10', '13:00:00', '15:00:00', 'B201', N'Cơ sở kỹ thuật xây dựng'),
('CK01_2024_1', '2024-09-10', '15:30:00', '17:30:00', 'C301', N'Cơ học chất rắn'),
('OT01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'D401', N'Hệ thống động cơ ô tô'),
('QT01_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'E501', N'Khái niệm quản trị');
GO

-- Thêm dữ liệu mẫu cho bảng Điểm danh (Attendance)
INSERT INTO Attendance (student_id, session_id, status, time_recorded, notes)
VALUES 
('SV001', 1, N'Có mặt', '2024-09-10 07:05:00', NULL),
('SV002', 1, N'Có mặt', '2024-09-10 07:06:00', NULL),
('SV003', 2, N'Có mặt', '2024-09-10 09:35:00', NULL),
('SV004', 3, N'Có mặt', '2024-09-10 13:05:00', NULL),
('SV005', 4, N'Đi muộn', '2024-09-10 15:45:00', N'Đến muộn 15 phút'),
('SV006', 5, N'Có mặt', '2024-09-10 07:05:00', NULL),
('SV007', 6, N'Có mặt', '2024-09-10 09:35:00', NULL);
GO

-- Thêm dữ liệu mẫu cho bảng Thái độ học tập (Learning_Attitude)
INSERT INTO Learning_Attitude (student_id, offering_id, participation_rate, focus_level, assignment_completion, discussion_participation, proactiveness, teamwork, respectfulness, notes, assessor_id, assessment_date)
VALUES 
('SV001', 'TH01_2024_1', 90.00, N'Tốt', 95.00, 8, N'Chủ động', N'Tốt', N'Tốt', N'Học sinh chăm chỉ', 'GV006', '2024-10-01'),
('SV002', 'TH01_2024_1', 85.00, N'Khá', 90.00, 7, N'Trung bình', N'Khá', N'Tốt', NULL, 'GV006', '2024-10-01'),
('SV003', 'TH02_2024_1', 80.00, N'Khá', 85.00, 6, N'Trung bình', N'Khá', N'Khá', NULL, 'GV006', '2024-10-01'),
('SV004', 'XD01_2024_1', 95.00, N'Xuất sắc', 100.00, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất tích cực', 'GV007', '2024-10-01'),
('SV005', 'CK01_2024_1', 70.00, N'Trung bình', 75.00, 5, N'Thụ động', N'Trung bình', N'Khá', N'Cần cải thiện', 'GV008', '2024-10-01'),
('SV006', 'OT01_2024_1', 90.00, N'Tốt', 95.00, 8, N'Chủ động', N'Tốt', N'Tốt', NULL, 'GV009', '2024-10-01'),
('SV007', 'QT01_2024_1', 85.00, N'Khá', 90.00, 7, N'Trung bình', N'Khá', N'Tốt', NULL, 'GV010', '2024-10-01');
GO

-- Thêm dữ liệu mẫu cho bảng Vi phạm kỷ luật (Discipline_Issues)
INSERT INTO Discipline_Issues (student_id, issue_date, violation_type, severity, resolution, reporter_id, notes)
VALUES 
('SV005', '2024-09-15', N'Đi học muộn', N'Nhẹ', N'Nhắc nhở', 'GV008', N'Đi muộn 3 buổi liên tiếp');
GO

-- Thêm dữ liệu mẫu cho bảng Điểm (Grades)
INSERT INTO Grades (registration_id, midterm_score, final_score, total_score, grade_letter)
VALUES 
(1, 8.50, 9.00, 8.75, 'A'),
(2, 7.50, 8.00, 7.75, 'B+'),
(3, 7.00, 7.50, 7.25, 'B'),
(4, 9.00, 9.50, 9.25, 'A+'),
(5, 6.50, 7.00, 6.75, 'C+'),
(6, 8.00, 8.50, 8.25, 'A'),
(7, 7.50, 8.00, 7.75, 'B+');
GO

-- Thêm dữ liệu mẫu cho bảng Điểm rèn luyện (Conduct_Scores)
INSERT INTO Conduct_Scores (student_id, semester, academic_year, self_score, class_score, faculty_score, final_score, classification, assessor_id, assessment_date)
VALUES 
('SV001', '1', '2024-2025', 85, 90, 88, 88, N'Tốt', 'GV001', '2024-12-01'),
('SV002', '1', '2024-2025', 80, 85, 83, 83, N'Khá', 'GV001', '2024-12-01'),
('SV003', '1', '2024-2025', 78, 80, 79, 79, N'Khá', 'GV006', '2024-12-01'),
('SV004', '1', '2024-2025', 90, 95, 93, 93, N'Xuất sắc', 'GV002', '2024-12-01'),
('SV005', '1', '2024-2025', 65, 70, 68, 68, N'Trung bình', 'GV003', '2024-12-01'),
('SV006', '1', '2024-2025', 85, 90, 88, 88, N'Tốt', 'GV004', '2024-12-01'),
('SV007', '1', '2024-2025', 80, 85, 83, 83, N'Khá', 'GV005', '2024-12-01');
GO



-- Thêm dữ liệu mẫu cho các bảng khác theo mẫu tương tự
-- 1. Truy vấn sinh viên có thái độ học tập kém
SELECT s.student_id, s.full_name, s.class_id, 
       AVG(CAST(la.participation_rate AS FLOAT)) AS avg_participation,
       AVG(CAST(la.assignment_completion AS FLOAT)) AS avg_assignment,
       COUNT(di.issue_id) AS violation_count
FROM Students s
LEFT JOIN Learning_Attitude la ON s.student_id = la.student_id
LEFT JOIN Discipline_Issues di ON s.student_id = di.student_id
WHERE la.assessment_date BETWEEN DATEADD(MONTH, -6, GETDATE()) AND GETDATE()
  AND di.issue_date BETWEEN DATEADD(MONTH, -6, GETDATE()) AND GETDATE()
GROUP BY s.student_id, s.full_name, s.class_id
HAVING AVG(CAST(la.participation_rate AS FLOAT)) < 70 
   OR AVG(CAST(la.assignment_completion AS FLOAT)) < 60 
   OR COUNT(di.issue_id) > 2
ORDER BY violation_count DESC, AVG(CAST(la.participation_rate AS FLOAT)) ASC;

-- 2. Truy vấn xu hướng thái độ học tập của sinh viên theo thời gian
SELECT 
    CONCAT(co.academic_year, N' - Học kỳ ', co.semester) AS semester_info,
    AVG(CAST(la.participation_rate AS FLOAT)) AS avg_participation,
    AVG(CAST(la.assignment_completion AS FLOAT)) AS avg_assignment,
    AVG(CASE 
        WHEN la.focus_level = N'Xuất sắc' THEN 5
        WHEN la.focus_level = N'Tốt' THEN 4
        WHEN la.focus_level = N'Khá' THEN 3
        WHEN la.focus_level = N'Trung bình' THEN 2
        WHEN la.focus_level = N'Kém' THEN 1
        END) AS avg_focus
FROM Learning_Attitude la
JOIN Course_Offerings co ON la.offering_id = co.offering_id
WHERE la.student_id = '2020601234'
GROUP BY CONCAT(co.academic_year, N' - Học kỳ ', co.semester), co.academic_year, co.semester
ORDER BY co.academic_year, co.semester;

-- 3. Truy vấn so sánh thái độ học tập giữa các lớp
SELECT c.class_id, c.class_name, d.department_name,
       COUNT(DISTINCT s.student_id) AS total_students,
       AVG(CAST(la.participation_rate AS FLOAT)) AS avg_participation,
       AVG(CAST(la.assignment_completion AS FLOAT)) AS avg_assignment,
       CAST(100.0 * SUM(CASE WHEN la.focus_level IN (N'Tốt', N'Xuất sắc') THEN 1 ELSE 0 END) / 
            NULLIF(COUNT(DISTINCT s.student_id), 0) AS DECIMAL(5,2)) AS good_focus_percentage
FROM Classes c
JOIN Departments d ON c.department_id = d.department_id
JOIN Students s ON c.class_id = s.class_id
LEFT JOIN Learning_Attitude la ON s.student_id = la.student_id
JOIN Course_Offerings co ON la.offering_id = co.offering_id
WHERE co.academic_year = '2024-2025' AND co.semester = '1'
GROUP BY c.class_id, c.class_name, d.department_name
ORDER BY avg_participation DESC;

-- 4. Truy vấn phân tích tương quan giữa điểm danh và kết quả học tập
SELECT s.student_id, s.full_name,
       COUNT(DISTINCT cs.session_id) AS total_sessions,
       SUM(CASE WHEN a.status = N'Có mặt' THEN 1 ELSE 0 END) AS attendance_count,
       CAST(100.0 * SUM(CASE WHEN a.status = N'Có mặt' THEN 1 ELSE 0 END) / 
            NULLIF(COUNT(DISTINCT cs.session_id), 0) AS DECIMAL(5,2)) AS attendance_rate,
       AVG(g.midterm_score) AS avg_midterm,
       AVG(g.final_score) AS avg_final,
       AVG(g.total_score) AS avg_total
FROM Students s
JOIN Attendance a ON s.student_id = a.student_id
JOIN Class_Sessions cs ON a.session_id = cs.session_id
JOIN Course_Offerings co ON cs.offering_id = co.offering_id
JOIN Course_Registration cr ON s.student_id = cr.student_id AND co.offering_id = cr.offering_id
JOIN Grades g ON cr.registration_id = g.registration_id
WHERE co.academic_year = '2024-2025' AND co.semester = '1'
GROUP BY s.student_id, s.full_name
ORDER BY attendance_rate DESC;

-- 5. Truy vấn cảnh báo sinh viên cần được theo dõi đặc biệt
WITH AbsenceCounts AS (
    SELECT 
        a.student_id,
        COUNT(*) AS absence_count
    FROM Attendance a 
    JOIN Class_Sessions cs ON a.session_id = cs.session_id
    JOIN Course_Offerings co ON cs.offering_id = co.offering_id
    WHERE co.academic_year = '2024-2025' 
      AND co.semester = '1' 
      AND a.status = N'Vắng mặt'
    GROUP BY a.student_id
)

SELECT s.student_id, s.full_name, s.class_id, s.phone, s.email,
       COUNT(DISTINCT di.issue_id) AS violation_count,
       MAX(di.issue_date) AS latest_violation_date,
       AVG(CAST(la.participation_rate AS FLOAT)) AS avg_participation,
       AVG(CAST(la.assignment_completion AS FLOAT)) AS avg_assignment,
       ISNULL(ac.absence_count, 0) AS absence_count,
       CASE
           WHEN COUNT(DISTINCT di.issue_id) >= 3 THEN N'Cảnh báo kỷ luật'
           WHEN AVG(CAST(la.participation_rate AS FLOAT)) < 50 THEN N'Cảnh báo thái độ'
           WHEN ISNULL(ac.absence_count, 0) > 5 THEN N'Cảnh báo vắng mặt'
           ELSE N'Bình thường'
       END AS warning_status
FROM Students s
LEFT JOIN Discipline_Issues di ON s.student_id = di.student_id AND di.issue_date BETWEEN '2024-08-01' AND '2024-12-31'
LEFT JOIN Learning_Attitude la ON s.student_id = la.student_id
LEFT JOIN Course_Offerings co ON la.offering_id = co.offering_id AND co.academic_year = '2024-2025' AND co.semester = '1'
LEFT JOIN AbsenceCounts ac ON s.student_id = ac.student_id
GROUP BY s.student_id, s.full_name, s.class_id, s.phone, s.email, ac.absence_count
HAVING CASE
           WHEN COUNT(DISTINCT di.issue_id) >= 3 THEN N'Cảnh báo kỷ luật'
           WHEN AVG(CAST(la.participation_rate AS FLOAT)) < 50 THEN N'Cảnh báo thái độ'
           WHEN ISNULL(ac.absence_count, 0) > 5 THEN N'Cảnh báo vắng mặt'
           ELSE N'Bình thường'
       END <> N'Bình thường'
ORDER BY 
    CASE
        WHEN CASE
                WHEN COUNT(DISTINCT di.issue_id) >= 3 THEN N'Cảnh báo kỷ luật'
                WHEN AVG(CAST(la.participation_rate AS FLOAT)) < 50 THEN N'Cảnh báo thái độ'
                WHEN ISNULL(ac.absence_count, 0) > 5 THEN N'Cảnh báo vắng mặt'
                ELSE N'Bình thường'
            END = N'Cảnh báo kỷ luật' THEN 1
        WHEN CASE
                WHEN COUNT(DISTINCT di.issue_id) >= 3 THEN N'Cảnh báo kỷ luật'
                WHEN AVG(CAST(la.participation_rate AS FLOAT)) < 50 THEN N'Cảnh báo thái độ'
                WHEN ISNULL(ac.absence_count, 0) > 5 THEN N'Cảnh báo vắng mặt'
                ELSE N'Bình thường'
            END = N'Cảnh báo thái độ' THEN 2
        WHEN CASE
                WHEN COUNT(DISTINCT di.issue_id) >= 3 THEN N'Cảnh báo kỷ luật'
                WHEN AVG(CAST(la.participation_rate AS FLOAT)) < 50 THEN N'Cảnh báo thái độ'
                WHEN ISNULL(ac.absence_count, 0) > 5 THEN N'Cảnh báo vắng mặt'
                ELSE N'Bình thường'
            END = N'Cảnh báo vắng mặt' THEN 3
        ELSE 4
    END;