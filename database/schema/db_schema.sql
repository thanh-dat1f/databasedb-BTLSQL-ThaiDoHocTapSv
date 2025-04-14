-- Tạo database
CREATE DATABASE [BTLSQL-ThaiDoHocTapSv];
GO
USE [BTLSQL-ThaiDoHocTapSv];
GO

-- Xóa các trigger trước
DROP TRIGGER IF EXISTS trg_Check_Max_Students;
DROP TRIGGER IF EXISTS trg_Check_Attendance_Date;
DROP TRIGGER IF EXISTS trg_Check_Student_Status;
DROP TRIGGER IF EXISTS trg_Check_Assessment_Current_Term;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Students;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Teachers;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Departments;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Majors;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Classes;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Subjects;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Course_Offerings;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Course_Registration;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Class_Sessions;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Attendance;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Learning_Attitude;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Discipline_Issues;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Grades;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Conduct_Scores;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Schedule;
DROP TRIGGER IF EXISTS trg_Update_Timestamp_Learning_Materials;
DROP TRIGGER IF EXISTS trg_Check_Registration_Period;
DROP TRIGGER IF EXISTS trg_Check_Attendance_Registration;
DROP TRIGGER IF EXISTS trg_Calculate_Total_Score;

-- Xóa các view và stored procedure trước
DROP VIEW IF EXISTS vw_Attendance_Rate;
DROP PROCEDURE IF EXISTS sp_Calculate_Conduct_Score;

-- Xóa các bảng theo thứ tự
DROP TABLE IF EXISTS Conduct_Scores;
DROP TABLE IF EXISTS Grades;
DROP TABLE IF EXISTS Discipline_Issues;
DROP TABLE IF EXISTS Learning_Attitude;
DROP TABLE IF EXISTS Attendance;
DROP TABLE IF EXISTS Class_Sessions;
DROP TABLE IF EXISTS Course_Registration;
DROP TABLE IF EXISTS Course_Offerings;
DROP TABLE IF EXISTS Subjects;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Classes;
DROP TABLE IF EXISTS Majors;
DROP TABLE IF EXISTS Teachers;
DROP TABLE IF EXISTS Departments;
DROP TABLE IF EXISTS Schedule;
DROP TABLE IF EXISTS Learning_Materials;

PRINT N'Đã xóa tất cả các bảng, trigger, view và stored procedure trong database [BTLSQL-ThaiDoHocTapSv]';

-- Bảng Khoa (Departments)
CREATE TABLE Departments (
    department_id VARCHAR(10) PRIMARY KEY,
    department_name NVARCHAR(100) NOT NULL,
    dean_name NVARCHAR(100),
    description NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

-- Bảng Giảng viên (Teachers) - Sửa email và thêm thông tin tài khoản
CREATE TABLE Teachers (
    teacher_id VARCHAR(10) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    gender NVARCHAR(10) NOT NULL CHECK (gender IN (N'Nam', N'Nữ', N'Khác')),
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'), -- Email cá nhân
    teacher_username VARCHAR(50) UNIQUE NOT NULL,
    teacher_password_hash VARCHAR(256) NOT NULL,
    phone VARCHAR(15) CHECK (phone IS NULL OR phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    department_id VARCHAR(10) NOT NULL,
    position NVARCHAR(50),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
GO

-- Bảng Ngành học (Majors)
CREATE TABLE Majors (
    major_id VARCHAR(10) PRIMARY KEY,
    major_name NVARCHAR(100) NOT NULL,
    department_id VARCHAR(10) NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
GO

-- Bảng Lớp (Classes)
CREATE TABLE Classes (
    class_id VARCHAR(10) PRIMARY KEY,
    class_name NVARCHAR(100) NOT NULL,
    department_id VARCHAR(10) NOT NULL,
    major_id VARCHAR(10) NOT NULL,
    homeroom_teacher_id VARCHAR(10),
    year_started INT NOT NULL CHECK (year_started >= 2000 AND year_started <= YEAR(GETDATE())),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id),
    FOREIGN KEY (major_id) REFERENCES Majors(major_id),
    FOREIGN KEY (homeroom_teacher_id) REFERENCES Teachers(teacher_id)
);
GO

-- Thêm ràng buộc giảng viên chủ nhiệm phải thuộc khoa của lớp
ALTER TABLE Classes ADD CONSTRAINT CHK_Homeroom_Teacher_Department
CHECK (
    homeroom_teacher_id IS NULL OR
    EXISTS (
        SELECT 1 FROM Teachers 
        WHERE Teachers.teacher_id = Classes.homeroom_teacher_id 
        AND Teachers.department_id = Classes.department_id
    )
);
GO

-- Bảng Sinh viên (Students) - Sửa email và thêm thông tin tài khoản
CREATE TABLE Students (
    student_id VARCHAR(10) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    dob DATE NOT NULL CHECK (dob < GETDATE()),
    gender NVARCHAR(10) NOT NULL CHECK (gender IN (N'Nam', N'Nữ', N'Khác')),
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@st.utc2.edu.vn'), -- Định dạng MSSV@st.utc2.edu.vn
    student_username VARCHAR(50) UNIQUE NOT NULL,
    student_password_hash VARCHAR(256) NOT NULL,
    phone VARCHAR(15) CHECK (phone IS NULL OR phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    address NVARCHAR(200),
    citizen_id VARCHAR(12) CHECK (citizen_id IS NULL OR citizen_id LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    guardian_info NVARCHAR(200),
    class_id VARCHAR(10) NOT NULL,
    major_id VARCHAR(10) NOT NULL,
    year_enrolled INT NOT NULL CHECK (year_enrolled >= 2000 AND year_enrolled <= YEAR(GETDATE())),
    status NVARCHAR(20) NOT NULL DEFAULT N'Đang học' CHECK (status IN (N'Đang học', N'Bảo lưu', N'Thôi học', N'Tốt nghiệp')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (class_id) REFERENCES Classes(class_id),
    FOREIGN KEY (major_id) REFERENCES Majors(major_id),
    CONSTRAINT CHK_Student_Min_Age CHECK (DATEDIFF(YEAR, dob, GETDATE()) >= 16)
);
GO

-- Thêm ràng buộc sinh viên phải thuộc lớp có ngành học tương ứng
ALTER TABLE Students ADD CONSTRAINT CHK_Student_Major_Class
CHECK (
    EXISTS (
        SELECT 1 FROM Classes 
        WHERE Classes.class_id = Students.class_id 
        AND Classes.major_id = Students.major_id
    )
);
GO

-- Bảng Môn học (Subjects)
CREATE TABLE Subjects (
    subject_id VARCHAR(10) PRIMARY KEY,
    subject_name NVARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits BETWEEN 1 AND 10),
    department_id VARCHAR(10) NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);
GO

-- Bảng Lớp học phần (Course_Offerings)
CREATE TABLE Course_Offerings (
    offering_id VARCHAR(20) PRIMARY KEY,
    subject_id VARCHAR(10) NOT NULL,
    teacher_id VARCHAR(10) NOT NULL,
    semester VARCHAR(3) NOT NULL CHECK (semester IN ('1', '2', N'Hè')),
    academic_year VARCHAR(9) NOT NULL CHECK (
        academic_year LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' AND
        CAST(SUBSTRING(academic_year, 1, 4) AS INT) + 1 = CAST(SUBSTRING(academic_year, 6, 4) AS INT)
    ),
    max_students INT NOT NULL CHECK (max_students > 0 AND max_students <= 200),
    registration_start_date DATE,
    registration_end_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES Teachers(teacher_id),
    CONSTRAINT CHK_Registration_Period CHECK (registration_end_date IS NULL OR registration_end_date > registration_start_date)
);
GO

-- Bảng Đăng ký học phần (Course_Registration)
CREATE TABLE Course_Registration (
    registration_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    offering_id VARCHAR(20) NOT NULL,
    registration_date DATETIME NOT NULL CHECK (registration_date <= GETDATE()),
    status NVARCHAR(20) NOT NULL CHECK (status IN (N'Đăng ký', N'Đang học', N'Hoàn thành', N'Đã hủy')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_StudentOffering UNIQUE (student_id, offering_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (offering_id) REFERENCES Course_Offerings(offering_id)
);
GO

-- Bảng Buổi học (Class_Sessions)
CREATE TABLE Class_Sessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    offering_id VARCHAR(20) NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(20) NOT NULL,
    topic NVARCHAR(200),
    status NVARCHAR(20) NOT NULL DEFAULT N'Chưa diễn ra' CHECK (status IN (N'Đã diễn ra', N'Chưa diễn ra', N'Hủy')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (offering_id) REFERENCES Course_Offerings(offering_id),
    CONSTRAINT CHK_Class_Session_Time CHECK (end_time > start_time)
);
GO

-- Bảng Điểm danh (Attendance)
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
GO

-- Bảng Thái độ học tập (Learning_Attitude)
CREATE TABLE Learning_Attitude (
    assessment_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    offering_id VARCHAR(20) NOT NULL,
    participation_rate DECIMAL(5,2) CHECK (participation_rate IS NULL OR participation_rate BETWEEN 0 AND 100),
    focus_level NVARCHAR(20) CHECK (focus_level IN (N'Kém', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc')),
    assignment_completion DECIMAL(5,2) CHECK (assignment_completion IS NULL OR assignment_completion BETWEEN 0 AND 100),
    discussion_participation INT CHECK (discussion_participation IS NULL OR discussion_participation BETWEEN 0 AND 10),
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
GO

-- Ràng buộc người đánh giá thái độ học tập phải là giảng viên phụ trách lớp
ALTER TABLE Learning_Attitude ADD CONSTRAINT CHK_Assessor_Is_Teacher
CHECK (
    EXISTS (
        SELECT 1 FROM Course_Offerings
        WHERE Course_Offerings.offering_id = Learning_Attitude.offering_id
        AND Course_Offerings.teacher_id = Learning_Attitude.assessor_id
    )
);
GO

-- Ràng buộc sinh viên phải đăng ký học phần mới được đánh giá
ALTER TABLE Learning_Attitude ADD CONSTRAINT CHK_Student_Registered
CHECK (
    EXISTS (
        SELECT 1 FROM Course_Registration
        WHERE Course_Registration.student_id = Learning_Attitude.student_id
        AND Course_Registration.offering_id = Learning_Attitude.offering_id
    )
);
GO

-- Ràng buộc đánh giá thái độ học tập phải sau ngày đăng ký
ALTER TABLE Learning_Attitude ADD CONSTRAINT CHK_Assessment_After_Registration
CHECK (
    assessment_date >= (
        SELECT MIN(registration_date)
        FROM Course_Registration
        WHERE Course_Registration.offering_id = Learning_Attitude.offering_id
        AND Course_Registration.student_id = Learning_Attitude.student_id
    )
);
GO

-- Bảng Vi phạm kỷ luật (Discipline_Issues)
CREATE TABLE Discipline_Issues (
    issue_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    issue_date DATE NOT NULL CHECK (issue_date <= GETDATE()),
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
GO

-- Bảng Điểm (Grades)
CREATE TABLE Grades (
    grade_id INT IDENTITY(1,1) PRIMARY KEY,
    registration_id INT NOT NULL,
    midterm_score DECIMAL(4,2) CHECK (midterm_score IS NULL OR midterm_score BETWEEN 0 AND 10),
    final_score DECIMAL(4,2) CHECK (final_score IS NULL OR final_score BETWEEN 0 AND 10),
    practical_score DECIMAL(4,2) CHECK (practical_score IS NULL OR practical_score BETWEEN 0 AND 10),
    total_score DECIMAL(4,2) CHECK (total_score IS NULL OR total_score BETWEEN 0 AND 10),
    grade_letter VARCHAR(2) CHECK (grade_letter IS NULL OR grade_letter IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F')),
    status NVARCHAR(20) NOT NULL DEFAULT N'Chờ duyệt' CHECK (status IN (N'Chờ duyệt', N'Đã duyệt')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_Registration UNIQUE (registration_id),
    FOREIGN KEY (registration_id) REFERENCES Course_Registration(registration_id)
);
GO

-- Bảng Điểm rèn luyện (Conduct_Scores)
CREATE TABLE Conduct_Scores (
    conduct_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id VARCHAR(10) NOT NULL,
    semester VARCHAR(1) NOT NULL CHECK (semester IN ('1', '2')),
    academic_year VARCHAR(9) NOT NULL CHECK (
        academic_year LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' AND
        CAST(SUBSTRING(academic_year, 1, 4) AS INT) + 1 = CAST(SUBSTRING(academic_year, 6, 4) AS INT)
    ),
    self_score INT CHECK (self_score IS NULL OR self_score BETWEEN 0 AND 100),
    class_score INT CHECK (class_score IS NULL OR class_score BETWEEN 0 AND 100),
    faculty_score INT CHECK (faculty_score IS NULL OR faculty_score BETWEEN 0 AND 100),
    final_score INT NOT NULL CHECK (final_score BETWEEN 0 AND 100),
    classification NVARCHAR(20) NOT NULL CHECK (classification IN (N'Xuất sắc', N'Tốt', N'Khá', N'Trung bình', N'Yếu', N'Kém')),
    assessor_id VARCHAR(10) NOT NULL,
    assessment_date DATE NOT NULL CHECK (assessment_date <= GETDATE()),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_StudentSemesterYear UNIQUE (student_id, semester, academic_year),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (assessor_id) REFERENCES Teachers(teacher_id)
);
GO

-- Bảng Lịch học (Schedule)
CREATE TABLE Schedule (
    schedule_id INT IDENTITY(1,1) PRIMARY KEY,
    offering_id VARCHAR(20) NOT NULL,
    day_of_week NVARCHAR(20) CHECK (day_of_week IN (N'Thứ 2', N'Thứ 3', N'Thứ 4', N'Thứ 5', N'Thứ 6', N'Thứ 7', N'Chủ nhật')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(20) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (offering_id) REFERENCES Course_Offerings(offering_id),
    CONSTRAINT CHK_Schedule_Time CHECK (end_time > start_time)
);
GO

-- Bảng Tài liệu học tập (Learning_Materials)
CREATE TABLE Learning_Materials (
    material_id INT IDENTITY(1,1) PRIMARY KEY,
    offering_id VARCHAR(20) NOT NULL,
    title NVARCHAR(200) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_by VARCHAR(10) NOT NULL,
    upload_date DATETIME DEFAULT GETDATE(),
    description NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (offering_id) REFERENCES Course_Offerings(offering_id),
    FOREIGN KEY (uploaded_by) REFERENCES Teachers(teacher_id)
);
GO

-- Trigger tự động cập nhật updated_at
CREATE TRIGGER trg_Update_Timestamp_Students
ON Students
AFTER UPDATE
AS
BEGIN
    UPDATE Students
    SET updated_at = GETDATE()
    FROM Students s
    INNER JOIN inserted i ON s.student_id = i.student_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Teachers
ON Teachers
AFTER UPDATE
AS
BEGIN
    UPDATE Teachers
    SET updated_at = GETDATE()
    FROM Teachers t
    INNER JOIN inserted i ON t.teacher_id = i.teacher_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Departments
ON Departments
AFTER UPDATE
AS
BEGIN
    UPDATE Departments
    SET updated_at = GETDATE()
    FROM Departments d
    INNER JOIN inserted i ON d.department_id = i.department_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Majors
ON Majors
AFTER UPDATE
AS
BEGIN
    UPDATE Majors
    SET updated_at = GETDATE()
    FROM Majors m
    INNER JOIN inserted i ON m.major_id = i.major_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Classes
ON Classes
AFTER UPDATE
AS
BEGIN
    UPDATE Classes
    SET updated_at = GETDATE()
    FROM Classes c
    INNER JOIN inserted i ON c.class_id = i.class_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Subjects
ON Subjects
AFTER UPDATE
AS
BEGIN
    UPDATE Subjects
    SET updated_at = GETDATE()
    FROM Subjects s
    INNER JOIN inserted i ON s.subject_id = i.subject_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Course_Offerings
ON Course_Offerings
AFTER UPDATE
AS
BEGIN
    UPDATE Course_Offerings
    SET updated_at = GETDATE()
    FROM Course_Offerings co
    INNER JOIN inserted i ON co.offering_id = i.offering_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Course_Registration
ON Course_Registration
AFTER UPDATE
AS
BEGIN
    UPDATE Course_Registration
    SET updated_at = GETDATE()
    FROM Course_Registration cr
    INNER JOIN inserted i ON cr.registration_id = i.registration_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Class_Sessions
ON Class_Sessions
AFTER UPDATE
AS
BEGIN
    UPDATE Class_Sessions
    SET updated_at = GETDATE()
    FROM Class_Sessions cs
    INNER JOIN inserted i ON cs.session_id = i.session_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Attendance
ON Attendance
AFTER UPDATE
AS
BEGIN
    UPDATE Attendance
    SET updated_at = GETDATE()
    FROM Attendance a
    INNER JOIN inserted i ON a.attendance_id = i.attendance_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Learning_Attitude
ON Learning_Attitude
AFTER UPDATE
AS
BEGIN
    UPDATE Learning_Attitude
    SET updated_at = GETDATE()
    FROM Learning_Attitude la
    INNER JOIN inserted i ON la.assessment_id = i.assessment_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Discipline_Issues
ON Discipline_Issues
AFTER UPDATE
AS
BEGIN
    UPDATE Discipline_Issues
    SET updated_at = GETDATE()
    FROM Discipline_Issues di
    INNER JOIN inserted i ON di.issue_id = i.issue_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Grades
ON Grades
AFTER UPDATE
AS
BEGIN
    UPDATE Grades
    SET updated_at = GETDATE()
    FROM Grades g
    INNER JOIN inserted i ON g.grade_id = i.grade_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Conduct_Scores
ON Conduct_Scores
AFTER UPDATE
AS
BEGIN
    UPDATE Conduct_Scores
    SET updated_at = GETDATE()
    FROM Conduct_Scores cs
    INNER JOIN inserted i ON cs.conduct_id = i.conduct_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Schedule
ON Schedule
AFTER UPDATE
AS
BEGIN
    UPDATE Schedule
    SET updated_at = GETDATE()
    FROM Schedule s
    INNER JOIN inserted i ON s.schedule_id = i.schedule_id;
END;
GO

CREATE TRIGGER trg_Update_Timestamp_Learning_Materials
ON Learning_Materials
AFTER UPDATE
AS
BEGIN
    UPDATE Learning_Materials
    SET updated_at = GETDATE()
    FROM Learning_Materials lm
    INNER JOIN inserted i ON lm.material_id = i.material_id;
END;
GO

-- Trigger kiểm tra số lượng sinh viên đăng ký
CREATE TRIGGER trg_Check_Max_Students
ON Course_Registration
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @offering_id VARCHAR(20);
    DECLARE @max_students INT;
    DECLARE @current_count INT;
    
    SELECT @offering_id = offering_id FROM inserted;
    
    SELECT @max_students = max_students 
    FROM Course_Offerings 
    WHERE offering_id = @offering_id;
    
    SELECT @current_count = COUNT(*) 
    FROM Course_Registration 
    WHERE offering_id = @offering_id AND status IN (N'Đăng ký', N'Đang học', N'Hoàn thành');
    
    IF @current_count > @max_students
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Số lượng sinh viên đăng ký đã vượt quá sĩ số tối đa của lớp học phần', 1;
    END
END;
GO

-- Trigger kiểm tra ngày điểm danh
CREATE TRIGGER trg_Check_Attendance_Date
ON Attendance
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Class_Sessions s ON i.session_id = s.session_id
        WHERE CAST(i.time_recorded AS DATE) != s.session_date
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, N'Ngày điểm danh phải trùng với ngày của buổi học', 1;
    END
END;
GO

-- Trigger kiểm tra trạng thái sinh viên
CREATE TRIGGER trg_Check_Student_Status
ON Course_Registration
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Students s ON i.student_id = s.student_id
        WHERE s.status = N'Thôi học' AND i.status IN (N'Đăng ký', N'Đang học')
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, N'Sinh viên đã thôi học không thể đăng ký hoặc tham gia học phần mới', 1;
    END
END;
GO

-- Trigger kiểm tra đánh giá thái độ học tập
CREATE TRIGGER trg_Check_Assessment_Current_Term
ON Learning_Attitude
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Course_Offerings co ON i.offering_id = co.offering_id
        JOIN Course_Registration cr ON cr.offering_id = co.offering_id AND cr.student_id = i.student_id
        WHERE i.assessment_date < cr.registration_date OR i.assessment_date > GETDATE()
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50004, N'Đánh giá thái độ học tập phải nằm trong khoảng thời gian của kỳ học', 1;
    END
END;
GO

-- Trigger kiểm tra thời gian đăng ký học phần
CREATE TRIGGER trg_Check_Registration_Period
ON Course_Registration
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Course_Offerings co ON i.offering_id = co.offering_id
        WHERE i.registration_date < co.registration_start_date OR i.registration_date > co.registration_end_date
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50005, N'Đăng ký học phần chỉ được thực hiện trong khoảng thời gian cho phép', 1;
    END
END;
GO

-- Trigger kiểm tra đăng ký trước khi điểm danh
CREATE TRIGGER trg_Check_Attendance_Registration
ON Attendance
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN Class_Sessions cs ON i.session_id = cs.session_id
        JOIN Course_Registration cr ON cr.student_id = i.student_id AND cr.offering_id = cs.offering_id
        WHERE cr.status IN (N'Đăng ký', N'Đang học', N'Hoàn thành')
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50006, N'Sinh viên chưa đăng ký học phần không thể điểm danh', 1;
    END
END;
GO

-- Trigger tính điểm tổng và chữ
CREATE TRIGGER trg_Calculate_Total_Score
ON Grades
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Grades
    SET total_score = (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5),
        grade_letter = CASE
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 9.0 THEN 'A+'
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 8.5 THEN 'A'
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 8.0 THEN 'B+'
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 7.0 THEN 'B'
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 6.5 THEN 'C+'
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 5.5 THEN 'C'
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 5.0 THEN 'D+'
            WHEN (COALESCE(midterm_score, 0) * 0.3 + COALESCE(practical_score, 0) * 0.2 + COALESCE(final_score, 0) * 0.5) >= 4.0 THEN 'D'
            ELSE 'F'
        END
    FROM Grades g
    INNER JOIN inserted i ON g.grade_id = i.grade_id
    WHERE i.midterm_score IS NOT NULL AND i.practical_score IS NOT NULL AND i.final_score IS NOT NULL;
END;
GO

-- Tạo chỉ mục (Index)
CREATE INDEX idx_student_id ON Course_Registration(student_id);
CREATE INDEX idx_offering_id ON Course_Registration(offering_id);
CREATE INDEX idx_session_id ON Attendance(session_id);
CREATE INDEX idx_student_id_attendance ON Attendance(student_id);
CREATE INDEX idx_offering_id_learning_attitude ON Learning_Attitude(offering_id);
CREATE INDEX idx_student_id_learning_attitude ON Learning_Attitude(student_id);
CREATE INDEX idx_student_id_discipline_issues ON Discipline_Issues(student_id);
CREATE INDEX idx_registration_id_grades ON Grades(registration_id);
CREATE INDEX idx_student_id_conduct_scores ON Conduct_Scores(student_id);
CREATE INDEX idx_offering_id_schedule ON Schedule(offering_id);
CREATE INDEX idx_offering_id_learning_materials ON Learning_Materials(offering_id);
GO

-- View tính tỷ lệ chuyên cần
CREATE VIEW vw_Attendance_Rate AS
SELECT 
    cr.student_id,
    cr.offering_id,
    COUNT(CASE WHEN a.status = N'Có mặt' THEN 1 END) * 100.0 / COUNT(a.attendance_id) AS attendance_rate
FROM Course_Registration cr
LEFT JOIN Class_Sessions cs ON cs.offering_id = cr.offering_id
LEFT JOIN Attendance a ON a.student_id = cr.student_id AND a.session_id = cs.session_id
WHERE cs.status = N'Đã diễn ra'
GROUP BY cr.student_id, cr.offering_id;
GO

-- Stored Procedure tính điểm rèn luyện
CREATE PROCEDURE sp_Calculate_Conduct_Score
    @student_id VARCHAR(10),
    @semester VARCHAR(1),
    @academic_year VARCHAR(9)
AS
BEGIN
    DECLARE @attitude_score DECIMAL(5,2);
    DECLARE @discipline_count INT;
    
    SELECT @attitude_score = AVG(participation_rate)
    FROM Learning_Attitude la
    JOIN Course_Offerings co ON la.offering_id = co.offering_id
    WHERE la.student_id = @student_id
    AND co.semester = @semester
    AND co.academic_year = @academic_year;
    
    SELECT @discipline_count = COUNT(*)
    FROM Discipline_Issues di
    WHERE di.student_id = @student_id
    AND YEAR(di.issue_date) = CAST(SUBSTRING(@academic_year, 1, 4) AS INT);
    
    UPDATE Conduct_Scores
    SET final_score = COALESCE(@attitude_score, 80) - (@discipline_count * 5),
        classification = CASE 
            WHEN final_score >= 90 THEN N'Xuất sắc'
            WHEN final_score >= 80 THEN N'Tốt'
            WHEN final_score >= 70 THEN N'Khá'
            WHEN final_score >= 60 THEN N'Trung bình'
            WHEN final_score >= 50 THEN N'Yếu'
            ELSE N'Kém'
        END
    WHERE student_id = @student_id
    AND semester = @semester
    AND academic_year = @academic_year;
END;
GO

-- Thêm dữ liệu mẫu
-- Departments
INSERT INTO Departments (department_id, department_name, dean_name, description)
VALUES 
('CNTT', N'Công nghệ thông tin', N'TS. Nguyễn Văn A', N'Khoa Công nghệ thông tin'),
('KTXD', N'Kỹ thuật xây dựng', N'TS. Lê Thị B', N'Khoa Kỹ thuật xây dựng'),
('KTCK', N'Kỹ thuật cơ khí', N'PGS.TS. Trần Văn C', N'Khoa Kỹ thuật cơ khí'),
('KTOTO', N'Kỹ thuật ô tô', N'TS. Phạm Thị D', N'Khoa Kỹ thuật ô tô'),
('QTKD', N'Quản trị kinh doanh', N'PGS.TS. Hoàng Văn E', N'Khoa Quản trị kinh doanh');
GO

-- Teachers
INSERT INTO Teachers (teacher_id, full_name, gender, email, teacher_username, teacher_password_hash, phone, department_id, position)
VALUES 
('GV001', N'Nguyễn Văn A', N'Nam', 'nguyenvana@gmail.com', 'nguyenvana', 'hashed_password_1', '0901234567', 'CNTT', N'Trưởng khoa'),
('GV002', N'Lê Thị B', N'Nữ', 'lethib@yahoo.com', 'lethib', 'hashed_password_2', '0912345678', 'KTXD', N'Trưởng khoa'),
('GV003', N'Trần Văn C', N'Nam', 'tranvanc@gmail.com', 'tranvanc', 'hashed_password_3', '0923456789', 'KTCK', N'Trưởng khoa'),
('GV004', N'Phạm Thị D', N'Nữ', 'phamthid@gmail.com', 'phamthid', 'hashed_password_4', '0934567890', 'KTOTO', N'Trưởng khoa'),
('GV005', N'Hoàng Văn E', N'Nam', 'hoangvane@gmail.com', 'hoangvane', 'hashed_password_5', '0945678901', 'QTKD', N'Trưởng khoa'),
('GV006', N'Trịnh Thị F', N'Nữ', 'trinhthif@gmail.com', 'trinhthif', 'hashed_password_6', '0956789012', 'CNTT', N'Giảng viên'),
('GV007', N'Lý Văn G', N'Nam', 'lyvang@yahoo.com', 'lyvang', 'hashed_password_7', '0967890123', 'KTXD', N'Giảng viên'),
('GV008', N'Đặng Thị H', N'Nữ', 'dangthih@gmail.com', 'dangthih', 'hashed_password_8', '0978901234', 'KTCK', N'Giảng viên'),
('GV009', N'Vũ Văn I', N'Nam', 'vuvani@gmail.com', 'vuvani', 'hashed_password_9', '0989012345', 'KTOTO', N'Giảng viên'),
('GV010', N'Ngô Thị K', N'Nữ', 'ngothik@yahoo.com', 'ngothik', 'hashed_password_10', '0990123456', 'QTKD', N'Giảng viên');
GO

-- Majors
INSERT INTO Majors (major_id, major_name, department_id, description)
VALUES 
('CNPM', N'Công nghệ phần mềm', 'CNTT', N'Ngành đào tạo về phát triển phần mềm'),
('KTPM', N'Kỹ thuật phần mềm', 'CNTT', N'Ngành đào tạo về kỹ thuật phần mềm'),
('XDDD', N'Xây dựng dân dụng', 'KTXD', N'Ngành đào tạo về xây dựng dân dụng và công nghiệp'),
('CNCK', N'Cơ khí chế tạo', 'KTCK', N'Ngành đào tạo về cơ khí chế tạo'),
('OTOKT', N'Kỹ thuật ô tô', 'KTOTO', N'Ngành đào tạo về kỹ thuật ô tô'),
('QTKD', N'Quản trị kinh doanh', 'QTKD', N'Ngành đào tạo về quản trị kinh doanh');
GO

-- Classes
INSERT INTO Classes (class_id, class_name, department_id, major_id, homeroom_teacher_id, year_started)
VALUES 
('CNPM01', N'Công nghệ phần mềm K45', 'CNTT', 'CNPM', 'GV001', 2023),
('KTPM01', N'Kỹ thuật phần mềm K45', 'CNTT', 'KTPM', 'GV006', 2023),
('XDDD01', N'Xây dựng dân dụng K45', 'KTXD', 'XDDD', 'GV002', 2023),
('CNCK01', N'Cơ khí chế tạo K45', 'KTCK', 'CNCK', 'GV003', 2023),
('OTOKT01', N'Kỹ thuật ô tô K45', 'KTOTO', 'OTOKT', 'GV004', 2023),
('QTKD01', N'Quản trị kinh doanh K45', 'QTKD', 'QTKD', 'GV005', 2023);
GO

-- Students
INSERT INTO Students (student_id, full_name, dob, gender, email, student_username, student_password_hash, phone, address, citizen_id, guardian_info, class_id, major_id, year_enrolled, status)
VALUES 
('SV001', N'Nguyễn Văn Hùng', '2003-05-10', N'Nam', 'SV001@st.utc2.edu.vn', 'nguyenvanhung', 'hashed_password_1', '0911111111', N'Hà Nội', '123456789012', N'Nguyễn Văn Ba', 'CNPM01', 'CNPM', 2023, N'Đang học'),
('SV002', N'Trần Thị Mai', '2003-07-15', N'Nữ', 'SV002@st.utc2.edu.vn', 'tranthimai', 'hashed_password_2', '0922222222', N'Hà Nội', '123456789013', N'Trần Văn An', 'CNPM01', 'CNPM', 2023, N'Đang học'),
('SV003', N'Lê Văn Nam', '2003-03-20', N'Nam', 'SV003@st.utc2.edu.vn', 'levannam', 'hashed_password_3', '0933333333', N'TP.HCM', '123456789014', N'Lê Thị Hoa', 'KTPM01', 'KTPM', 2023, N'Đang học'),
('SV004', N'Phạm Thị Lan', '2003-09-25', N'Nữ', 'SV004@st.utc2.edu.vn', 'phamthilan', 'hashed_password_4', '0944444444', N'Đà Nẵng', '123456789015', N'Phạm Văn Tâm', 'XDDD01', 'XDDD', 2023, N'Đang học'),
('SV005', N'Hoàng Văn Tùng', '2003-11-30', N'Nam', 'SV005@st.utc2.edu.vn', 'hoangvantung', 'hashed_password_5', '0955555555', N'Hà Nội', '123456789016', N'Hoàng Thị Mai', 'CNCK01', 'CNCK', 2023, N'Đang học'),
('SV006', N'Ngô Thị Hoa', '2003-01-12', N'Nữ', 'SV006@st.utc2.edu.vn', 'ngothihoa', 'hashed_password_6', '0966666666', N'Hải Phòng', '123456789017', N'Ngô Văn Long', 'OTOKT01', 'OTOKT', 2023, N'Đang học'),
('SV007', N'Vũ Văn Long', '2003-06-18', N'Nam', 'SV007@st.utc2.edu.vn', 'vuvanlong', 'hashed_password_7', '0977777777', N'Hà Nội', '123456789018', N'Vũ Thị Hương', 'QTKD01', 'QTKD', 2023, N'Đang học');
GO

-- Subjects
INSERT INTO Subjects (subject_id, subject_name, credits, department_id, description)
VALUES 
('TH01', N'Lập trình cơ bản', 3, 'CNTT', N'Môn học về lập trình cơ bản với C++'),
('TH02', N'Cấu trúc dữ liệu', 3, 'CNTT', N'Môn học về cấu trúc dữ liệu và giải thuật'),
('XD01', N'Kỹ thuật xây dựng', 3, 'KTXD', N'Môn học về kỹ thuật xây dựng cơ bản'),
('CK01', N'Cơ học kỹ thuật', 3, 'KTCK', N'Môn học về cơ học kỹ thuật'),
('OT01', N'Kỹ thuật ô tô cơ bản', 3, 'KTOTO', N'Môn học về kỹ thuật ô tô'),
('QT01', N'Quản trị học', 3, 'QTKD', N'Môn học về quản trị học cơ bản');
GO

-- Course_Offerings
INSERT INTO Course_Offerings (offering_id, subject_id, teacher_id, semester, academic_year, max_students, registration_start_date, registration_end_date)
VALUES 
('TH01_2024_1', 'TH01', 'GV006', '1', '2024-2025', 50, '2024-07-15', '2024-08-15'),
('TH02_2024_1', 'TH02', 'GV006', '1', '2024-2025', 50, '2024-07-15', '2024-08-15'),
('XD01_2024_1', 'XD01', 'GV007', '1', '2024-2025', 50, '2024-07-15', '2024-08-15'),
('CK01_2024_1', 'CK01', 'GV008', '1', '2024-2025', 50, '2024-07-15', '2024-08-15'),
('OT01_2024_1', 'OT01', 'GV009', '1', '2024-2025', 50, '2024-07-15', '2024-08-15'),
('QT01_2024_1', 'QT01', 'GV010', '1', '2024-2025', 50, '2024-07-15', '2024-08-15');
GO

-- Schedule
INSERT INTO Schedule (offering_id, day_of_week, start_time, end_time, room)
VALUES 
('TH01_2024_1', N'Thứ 2', '07:00:00', '09:00:00', 'A101'),
('TH02_2024_1', N'Thứ 3', '09:30:00', '11:30:00', 'A102'),
('XD01_2024_1', N'Thứ 4', '13:00:00', '15:00:00', 'B201'),
('CK01_2024_1', N'Thứ 5', '15:30:00', '17:30:00', 'C301'),
('OT01_2024_1', N'Thứ 6', '07:00:00', '09:00:00', 'D401'),
('QT01_2024_1', N'Thứ 2', '09:30:00', '11:30:00', 'E501');
GO

-- Course_Registration
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

-- Class_Sessions
INSERT INTO Class_Sessions (offering_id, session_date, start_time, end_time, room, topic, status)
VALUES 
('TH01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'A101', N'Giới thiệu lập trình C++', N'Đã diễn ra'),
('TH02_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'A102', N'Mảng và con trỏ', N'Đã diễn ra'),
('XD01_2024_1', '2024-09-10', '13:00:00', '15:00:00', 'B201', N'Cơ sở kỹ thuật xây dựng', N'Đã diễn ra'),
('CK01_2024_1', '2024-09-10', '15:30:00', '17:30:00', 'C301', N'Cơ học chất rắn', N'Đã diễn ra'),
('OT01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'D401', N'Hệ thống động cơ ô tô', N'Đã diễn ra'),
('QT01_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'E501', N'Khái niệm quản trị', N'Đã diễn ra');
GO

-- Attendance
INSERT INTO Attendance (student_id, session_id, status, time_recorded, notes)
VALUES 
('SV001', 1, N'Có mặt', '2024-09-10 07:05:00', NULL),
('SV002', 1, N'Có mặt', '2024-09-10 07:06:00', NULL),
('SV003', 2, N'Có mặt', '2024-09-10 09:35:00', NULL),
('SV004', 3, N'Có mặt', '2024-09-10 13:05:00', NULL),
('SV005', 4, N'Đi muộn', '2024-09-10 15:45:00', N'Đến muộn 15 phút'),
('SV006', 5, N'Có mặt', '2024-09-10 07:05:00', NULL),
('SV007', 6, N'Có mặt', '2024-09-10 09:35:00', NULL),
('SV005', 4, N'Vắng mặt', '2024-09-10 15:30:00', N'Không có lý do'),
('SV002', 1, N'Có phép', '2024-09-10 07:00:00', N'Xin nghỉ ốm');
GO

-- Learning_Attitude
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

-- Discipline_Issues
INSERT INTO Discipline_Issues (student_id, issue_date, violation_type, severity, resolution, reporter_id, notes)
VALUES 
('SV005', '2024-09-15', N'Đi học muộn', N'Nhẹ', N'Nhắc nhở', 'GV008', N'Đi muộn 3 buổi liên tiếp'),
('SV003', '2024-09-20', N'Sao chép bài tập', N'Trung bình', N'Giảm điểm bài tập', 'GV006', N'Sao chép bài của bạn'),
('SV002', '2024-09-25', N'Vô lễ với giảng viên', N'Nghiêm trọng', N'Cảnh cáo', 'GV006', N'Tỏ thái độ không tôn trọng');
GO

-- Grades
INSERT INTO Grades (registration_id, midterm_score, practical_score, final_score, total_score, grade_letter, status)
VALUES 
(1, 8.50, 9.00, 9.00, 8.85, 'A', N'Đã duyệt'),
(2, 7.50, 8.00, 8.00, 7.75, 'B+', N'Đã duyệt'),
(3, 7.00, 7.50, 7.50, 7.35, 'B', N'Đã duyệt'),
(4, 9.00, 9.50, 9.50, 9.35, 'A+', N'Đã duyệt'),
(5, 6.50, 7.00, 7.00, 6.75, 'C+', N'Đã duyệt'),
(6, 8.00, 8.50, 8.50, 8.35, 'A', N'Đã duyệt'),
(7, 7.50, 8.00, 8.00, 7.75, 'B+', N'Đã duyệt');
GO

-- Conduct_Scores
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

-- Learning_Materials
INSERT INTO Learning_Materials (offering_id, title, file_path, uploaded_by, description)
VALUES 
('TH01_2024_1', N'Slide bài giảng lập trình C++', '/materials/th01/slide1.pdf', 'GV006', N'Slide giới thiệu lập trình C++'),
('TH02_2024_1', N'Bài tập mảng', '/materials/th02/assignment1.pdf', 'GV006', N'Bài tập về mảng và con trỏ'),
('XD01_2024_1', N'Tài liệu kỹ thuật xây dựng', '/materials/xd01/doc1.pdf', 'GV007', N'Tài liệu cơ bản về kỹ thuật xây dựng'),
('CK01_2024_1', N'Slide cơ học chất rắn', '/materials/ck01/slide1.pdf', 'GV008', N'Slide bài giảng cơ học chất rắn'),
('OT01_2024_1', N'Hướng dẫn hệ thống động cơ', '/materials/ot01/guide1.pdf', 'GV009', N'Hướng dẫn hệ thống động cơ ô tô'),
('QT01_2024_1', N'Slide quản trị học', '/materials/qt01/slide1.pdf', 'GV010', N'Slide khái niệm quản trị học');
GO

PRINT N'Đã tạo database và thêm dữ liệu mẫu thành công!';