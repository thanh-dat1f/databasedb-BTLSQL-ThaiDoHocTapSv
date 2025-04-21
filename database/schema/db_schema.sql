
CREATE DATABASE QuanLyThaiDoHocTap;
GO
USE QuanLyThaiDoHocTap;
GO
USE master;
GO

-- Đặt cơ sở dữ liệu vào chế độ single user để ngắt các kết nối khác
ALTER DATABASE QuanLyThaiDoHocTap SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Sau đó xóa cơ sở dữ liệu
DROP DATABASE QuanLyThaiDoHocTap;

-- Xóa các trigger nếu tồn tại
DROP TRIGGER IF EXISTS trg_KiemTra_DangKy_ThaiDoHocTap;
GO
DROP TRIGGER IF EXISTS trg_KiemTra_QuyenDanhGia;
GO
DROP TRIGGER IF EXISTS trg_TinhDiemTongHop_ThaiDoHocTap;
GO
DROP TRIGGER IF EXISTS trg_CapNhat_DiemRenLuyen;
GO
DROP TRIGGER IF EXISTS trg_CapNhat_DiemRenLuyen_ViPham;
GO
DROP TRIGGER IF EXISTS trg_CapNhat_TyLeThamGia;
GO
DROP TRIGGER IF EXISTS trg_KiemTra_DiemDanh_DangKy;
GO
DROP TRIGGER IF EXISTS trg_KiemTra_DuLieu_ThaiDoHocTap;
GO
-- Script xóa toàn bộ bảng
-- Script xóa toàn bộ bảng an toàn
DROP TABLE IF EXISTS ChiTietDanhGia;
DROP TABLE IF EXISTS DiemDanh;
DROP TABLE IF EXISTS DanhGiaThaiDoHocTap;
DROP TABLE IF EXISTS ViPhamKyLuat;
DROP TABLE IF EXISTS DiemRenLuyen;
DROP TABLE IF EXISTS DangKyHocPhan;
DROP TABLE IF EXISTS BuoiHoc;
DROP TABLE IF EXISTS LopHocPhan;
DROP TABLE IF EXISTS TieuChiDanhGia;
DROP TABLE IF EXISTS MonHoc;
DROP TABLE IF EXISTS SinhVien;
DROP TABLE IF EXISTS Lop;
DROP TABLE IF EXISTS GiangVien;
DROP TABLE IF EXISTS NganhHoc;
DROP TABLE IF EXISTS Khoa;


-- Tạo bảng Khoa
CREATE TABLE Khoa (
    maKhoa VARCHAR(10) PRIMARY KEY,
    tenKhoa NVARCHAR(100) NOT NULL,
    truongKhoa NVARCHAR(100),
    moTa NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE()
);
GO

-- Tạo bảng Ngành học
CREATE TABLE NganhHoc (
    maNganh VARCHAR(10) PRIMARY KEY,
    tenNganh NVARCHAR(100) NOT NULL,
    maKhoa VARCHAR(10) NOT NULL,
    moTa NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa)
);
GO

-- Tạo bảng Giảng viên
CREATE TABLE GiangVien (
    maGiangVien VARCHAR(10) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    gioiTinh NVARCHAR(10) NOT NULL CHECK (gioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
    soDienThoai VARCHAR(15),
    maKhoa VARCHAR(10) NOT NULL,
    chucVu NVARCHAR(50),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa)
);
GO

-- Tạo bảng Lớp học
CREATE TABLE Lop (
    maLop VARCHAR(10) PRIMARY KEY,
    tenLop NVARCHAR(100) NOT NULL,
    maKhoa VARCHAR(10) NOT NULL,
    maNganh VARCHAR(10) NOT NULL,
    maGVCN VARCHAR(10),
    namBatDau INT NOT NULL CHECK (namBatDau >= 2000 AND namBatDau <= YEAR(GETDATE())),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa),
    FOREIGN KEY (maNganh) REFERENCES NganhHoc(maNganh),
    FOREIGN KEY (maGVCN) REFERENCES GiangVien(maGiangVien)
);
GO

-- Tạo bảng Sinh viên
CREATE TABLE SinhVien (
    maSinhVien VARCHAR(10) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    ngaySinh DATE NOT NULL CHECK (ngaySinh < GETDATE()),
    gioiTinh NVARCHAR(10) NOT NULL CHECK (gioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    email VARCHAR(100) UNIQUE NOT NULL,
    soDienThoai VARCHAR(15),
    diaChi NVARCHAR(200),
    CCCD VARCHAR(12),
    maLop VARCHAR(10) NOT NULL,
    maNganh VARCHAR(10) NOT NULL,
    maKhoa VARCHAR(10) NOT NULL,
    namNhapHoc INT NOT NULL CHECK (namNhapHoc >= 2000 AND namNhapHoc <= YEAR(GETDATE())),
    trangThai NVARCHAR(20) NOT NULL DEFAULT N'Đang học' CHECK (trangThai IN (N'Đang học', N'Bảo lưu', N'Thôi học', N'Tốt nghiệp')),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maLop) REFERENCES Lop(maLop),
    FOREIGN KEY (maNganh) REFERENCES NganhHoc(maNganh),
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa)
);
GO

-- Tạo bảng Môn học
CREATE TABLE MonHoc (
    maMonHoc VARCHAR(10) PRIMARY KEY,
    tenMonHoc NVARCHAR(100) NOT NULL,
    soTinChi INT NOT NULL CHECK (soTinChi BETWEEN 1 AND 10),
    maKhoa VARCHAR(10) NOT NULL,
    moTa NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa)
);
GO

-- Tạo bảng Tiêu chí đánh giá thái độ học tập
CREATE TABLE TieuChiDanhGia (
    maTieuChi VARCHAR(10) PRIMARY KEY,
    tenTieuChi NVARCHAR(100) NOT NULL,
    loaiTieuChi NVARCHAR(50) NOT NULL CHECK (loaiTieuChi IN (N'Tham gia', N'Tập trung', N'Hoàn thành', N'Thảo luận', N'Chủ động', N'Làm việc nhóm', N'Tôn trọng', N'Kỷ luật')),
    moTa NVARCHAR(MAX),
    diemToiDa INT NOT NULL CHECK (diemToiDa > 0),
    trongSo DECIMAL(3,2) NOT NULL CHECK (trongSo > 0 AND trongSo <= 1.00),
    ngayTao DATETIME DEFAULT GETDATE()
);
GO

-- Tạo bảng Lớp học phần
CREATE TABLE LopHocPhan (
    maLHP VARCHAR(20) PRIMARY KEY,
    maMonHoc VARCHAR(10) NOT NULL,
    maGiangVien VARCHAR(10) NOT NULL,
    hocKy VARCHAR(3) NOT NULL CHECK (hocKy IN ('1', '2', N'Hè')),
    namHoc VARCHAR(9) NOT NULL CHECK (
        namHoc LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' AND
        CAST(SUBSTRING(namHoc, 1, 4) AS INT) + 1 = CAST(SUBSTRING(namHoc, 6, 4) AS INT)
    ),
    siSoToiDa INT NOT NULL CHECK (siSoToiDa > 0 AND siSoToiDa <= 200),
    soSinhVienHienTai INT DEFAULT 0,
    ngayBatDau DATE NOT NULL,
    ngayKetThuc DATE NOT NULL,
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maMonHoc) REFERENCES MonHoc(maMonHoc),
    FOREIGN KEY (maGiangVien) REFERENCES GiangVien(maGiangVien),
    CONSTRAINT CHK_NgayHocPhan CHECK (ngayKetThuc > ngayBatDau)
);
GO

-- Tạo bảng Đăng ký học phần
CREATE TABLE DangKyHocPhan (
    maDangKy INT IDENTITY(1,1) PRIMARY KEY,
    maSinhVien VARCHAR(10) NOT NULL,
    maLHP VARCHAR(20) NOT NULL,
    ngayDangKy DATE NOT NULL DEFAULT GETDATE(),
    trangThai NVARCHAR(20) NOT NULL CHECK (trangThai IN (N'Đăng ký', N'Đang học', N'Hoàn thành', N'Đã hủy')),
    diemGiuaKy DECIMAL(4,2) CHECK (diemGiuaKy IS NULL OR diemGiuaKy BETWEEN 0 AND 10),
    diemCuoiKy DECIMAL(4,2) CHECK (diemCuoiKy IS NULL OR diemCuoiKy BETWEEN 0 AND 10),
    diemThucHanh DECIMAL(4,2) CHECK (diemThucHanh IS NULL OR diemThucHanh BETWEEN 0 AND 10),
    diemTong DECIMAL(4,2) CHECK (diemTong IS NULL OR diemTong BETWEEN 0 AND 10),
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienLopHocPhan UNIQUE (maSinhVien, maLHP),
    FOREIGN KEY (maSinhVien) REFERENCES SinhVien(maSinhVien),
    FOREIGN KEY (maLHP) REFERENCES LopHocPhan(maLHP)
);
GO

-- Tạo bảng Buổi học
CREATE TABLE BuoiHoc (
    maBuoi INT IDENTITY(1,1) PRIMARY KEY,
    maLHP VARCHAR(20) NOT NULL,
    ngayHoc DATE NOT NULL,
    gioBatDau TIME NOT NULL,
    gioKetThuc TIME NOT NULL,
    phongHoc VARCHAR(20) NOT NULL,
    chuDe NVARCHAR(200),
    trangThai NVARCHAR(20) NOT NULL DEFAULT N'Chưa diễn ra' CHECK (trangThai IN (N'Đã diễn ra', N'Chưa diễn ra', N'Hủy')),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maLHP) REFERENCES LopHocPhan(maLHP),
    CONSTRAINT CHK_ThoiGianBuoiHoc CHECK (gioKetThuc > gioBatDau)
);
GO

-- Tạo bảng Điểm danh
CREATE TABLE DiemDanh (
    maDiemDanh INT IDENTITY(1,1) PRIMARY KEY,
    maSinhVien VARCHAR(10) NOT NULL,
    maBuoi INT NOT NULL,
    trangThai NVARCHAR(20) NOT NULL CHECK (trangThai IN (N'Có mặt', N'Vắng mặt', N'Đi muộn', N'Có phép')),
    thoiGianGhi DATETIME NOT NULL,
    ghiChu NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienBuoiHoc UNIQUE (maSinhVien, maBuoi),
    FOREIGN KEY (maSinhVien) REFERENCES SinhVien(maSinhVien),
    FOREIGN KEY (maBuoi) REFERENCES BuoiHoc(maBuoi)
);
GO

-- Tạo bảng Đánh giá thái độ học tập
CREATE TABLE DanhGiaThaiDoHocTap (
    maDanhGia INT IDENTITY(1,1) PRIMARY KEY,
    maSinhVien VARCHAR(10) NOT NULL,
    maLHP VARCHAR(20) NOT NULL,
    ngayDanhGia DATE NOT NULL DEFAULT GETDATE(),
    nguoiDanhGia VARCHAR(10) NOT NULL,
    tyLeThamGia DECIMAL(5,2) CHECK (tyLeThamGia BETWEEN 0 AND 100),
    mucDoTapTrung NVARCHAR(20) CHECK (mucDoTapTrung IN (N'Kém', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc')),
    hoanThanhBaiTap DECIMAL(5,2) CHECK (hoanThanhBaiTap BETWEEN 0 AND 100),
    thamGiaThaoLuan INT CHECK (thamGiaThaoLuan BETWEEN 0 AND 10),
    tinhChuDong NVARCHAR(20) CHECK (tinhChuDong IN (N'Thụ động', N'Trung bình', N'Chủ động')),
    lamViecNhom NVARCHAR(20) CHECK (lamViecNhom IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')),
    tonTrong NVARCHAR(20) CHECK (tonTrong IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')),
    diemTongHop DECIMAL(5,2) CHECK (diemTongHop BETWEEN 0 AND 100),
    xepLoai NVARCHAR(20) CHECK (xepLoai IN (N'Kém', N'Yếu', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc')),
    ghiChu NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maSinhVien) REFERENCES SinhVien(maSinhVien),
    FOREIGN KEY (maLHP) REFERENCES LopHocPhan(maLHP),
    FOREIGN KEY (nguoiDanhGia) REFERENCES GiangVien(maGiangVien),
    CONSTRAINT UQ_DanhGia_SinhVien_LHP UNIQUE (maSinhVien, maLHP)
);
GO

-- Tạo bảng Vi phạm kỷ luật
CREATE TABLE ViPhamKyLuat (
    maViPham INT IDENTITY(1,1) PRIMARY KEY,
    maSinhVien VARCHAR(10) NOT NULL,
    maLHP VARCHAR(20),
    ngayViPham DATE NOT NULL,
    loaiViPham NVARCHAR(100) NOT NULL,
    mucDoViPham NVARCHAR(20) NOT NULL CHECK (mucDoViPham IN (N'Nhẹ', N'Trung bình', N'Nghiêm trọng', N'Rất nghiêm trọng')),
    bienPhapXuLy NVARCHAR(200) NOT NULL,
    diemTru INT NOT NULL CHECK (diemTru BETWEEN 0 AND 100),
    nguoiXuLy VARCHAR(10) NOT NULL,
    trangThai NVARCHAR(20) CHECK (trangThai IN (N'Chờ xử lý', N'Đã xử lý', N'Đã khắc phục')),
    ghiChu NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maSinhVien) REFERENCES SinhVien(maSinhVien),
    FOREIGN KEY (maLHP) REFERENCES LopHocPhan(maLHP),
    FOREIGN KEY (nguoiXuLy) REFERENCES GiangVien(maGiangVien)
);
GO

-- Tạo bảng Điểm rèn luyện tổng hợp học kỳ
CREATE TABLE DiemRenLuyen (
    maDiemRenLuyen INT IDENTITY(1,1) PRIMARY KEY,
    maSinhVien VARCHAR(10) NOT NULL,
    hocKy VARCHAR(1) NOT NULL CHECK (hocKy IN ('1', '2')),
    namHoc VARCHAR(9) NOT NULL CHECK (
        namHoc LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' AND
        CAST(SUBSTRING(namHoc, 1, 4) AS INT) + 1 = CAST(SUBSTRING(namHoc, 6, 4) AS INT)
    ),
    diemTuDanhGia INT CHECK (diemTuDanhGia BETWEEN 0 AND 100),
    diemLop INT CHECK (diemLop BETWEEN 0 AND 100),
    diemKhoa INT CHECK (diemKhoa BETWEEN 0 AND 100),
    diemCuoiCung INT NOT NULL CHECK (diemCuoiCung BETWEEN 0 AND 100),
    xepLoai NVARCHAR(20) NOT NULL CHECK (xepLoai IN (N'Xuất sắc', N'Tốt', N'Khá', N'Trung bình', N'Yếu', N'Kém')),
    nguoiDanhGia VARCHAR(10) NOT NULL,
    ngayDanhGia DATE NOT NULL DEFAULT GETDATE(),
    coHocBong BIT DEFAULT 0,
    loaiHocBong NVARCHAR(50) CHECK (loaiHocBong IS NULL OR loaiHocBong IN (N'Xuất sắc', N'Khá')),
    giaTriHocBong DECIMAL(10,2) CHECK (giaTriHocBong IS NULL OR giaTriHocBong >= 0),
    ghiChu NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienHocKyNamHoc UNIQUE (maSinhVien, hocKy, namHoc),
    FOREIGN KEY (maSinhVien) REFERENCES SinhVien(maSinhVien),
    FOREIGN KEY (nguoiDanhGia) REFERENCES GiangVien(maGiangVien)
);
GO

-- Tạo bảng Chi tiết đánh giá theo tiêu chí
CREATE TABLE ChiTietDanhGia (
    maChiTiet INT IDENTITY(1,1) PRIMARY KEY,
    maDanhGia INT NOT NULL,
    maTieuChi VARCHAR(10) NOT NULL,
    diem INT NOT NULL,
    ghiChu NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maDanhGia) REFERENCES DanhGiaThaiDoHocTap(maDanhGia) ON DELETE CASCADE,
    FOREIGN KEY (maTieuChi) REFERENCES TieuChiDanhGia(maTieuChi),
    CONSTRAINT UQ_DanhGia_TieuChi UNIQUE (maDanhGia, maTieuChi)
);
GO

-- Tạo các chỉ mục để cải thiện hiệu suất
CREATE INDEX IX_DanhGiaThaiDoHocTap_maSinhVien ON DanhGiaThaiDoHocTap(maSinhVien);
CREATE INDEX IX_DanhGiaThaiDoHocTap_maLHP ON DanhGiaThaiDoHocTap(maLHP);
CREATE INDEX IX_ViPhamKyLuat_maSinhVien ON ViPhamKyLuat(maSinhVien);
CREATE INDEX IX_DiemDanh_maSinhVien ON DiemDanh(maSinhVien);
CREATE INDEX IX_DiemDanh_maBuoi ON DiemDanh(maBuoi);
CREATE INDEX IX_DiemRenLuyen_maSinhVien ON DiemRenLuyen(maSinhVien);
GO

-- Trigger kiểm tra sinh viên đã đăng ký học phần
CREATE TRIGGER trg_KiemTra_DangKy_ThaiDoHocTap
ON DanhGiaThaiDoHocTap
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM DangKyHocPhan dkhp
            WHERE dkhp.maSinhVien = i.maSinhVien
            AND dkhp.maLHP = i.maLHP
            AND dkhp.trangThai != N'Đã hủy'
        )
    )
    BEGIN
        RAISERROR (N'Không thể đánh giá thái độ học tập cho sinh viên chưa đăng ký hoặc đã hủy đăng ký lớp học phần.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger kiểm tra quyền đánh giá
CREATE TRIGGER trg_KiemTra_QuyenDanhGia
ON DanhGiaThaiDoHocTap
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE NOT EXISTS (
            SELECT 1
            FROM LopHocPhan lhp
            WHERE lhp.maLHP = i.maLHP
            AND lhp.maGiangVien = i.nguoiDanhGia
        )
    )
    BEGIN
        RAISERROR (N'Chỉ giảng viên dạy lớp học phần mới có quyền đánh giá thái độ học tập.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger tự động tính điểm tổng hợp và xếp loại
CREATE TRIGGER trg_TinhDiemTongHop_ThaiDoHocTap
ON DanhGiaThaiDoHocTap
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DanhGiaThaiDoHocTap
    SET 
        diemTongHop = (
            i.tyLeThamGia * 0.2 + 
            (CASE 
                WHEN i.mucDoTapTrung = N'Xuất sắc' THEN 100
                WHEN i.mucDoTapTrung = N'Tốt' THEN 85
                WHEN i.mucDoTapTrung = N'Khá' THEN 70
                WHEN i.mucDoTapTrung = N'Trung bình' THEN 50
                ELSE 30
             END) * 0.2 + 
            i.hoanThanhBaiTap * 0.2 + 
            i.thamGiaThaoLuan * 10 * 0.15 + 
            (CASE
                WHEN i.tinhChuDong = N'Chủ động' THEN 100
                WHEN i.tinhChuDong = N'Trung bình' THEN 70
                ELSE 40
             END) * 0.1 +
            (CASE
                WHEN i.lamViecNhom = N'Tốt' THEN 100
                WHEN i.lamViecNhom = N'Khá' THEN 80
                WHEN i.lamViecNhom = N'Trung bình' THEN 60
                ELSE 40
             END) * 0.1 +
            (CASE
                WHEN i.tonTrong = N'Tốt' THEN 100
                WHEN i.tonTrong = N'Khá' THEN 80
                WHEN i.tonTrong = N'Trung bình' THEN 60
                ELSE 40
             END) * 0.05
        ),
        xepLoai = 
            CASE 
                WHEN (i.tyLeThamGia * 0.2 + 
                     (CASE 
                        WHEN i.mucDoTapTrung = N'Xuất sắc' THEN 100
                        WHEN i.mucDoTapTrung = N'Tốt' THEN 85
                        WHEN i.mucDoTapTrung = N'Khá' THEN 70
                        WHEN i.mucDoTapTrung = N'Trung bình' THEN 50
                        ELSE 30
                     END) * 0.2 + 
                    i.hoanThanhBaiTap * 0.2 + 
                    i.thamGiaThaoLuan * 10 * 0.15 + 
                    (CASE
                        WHEN i.tinhChuDong = N'Chủ động' THEN 100
                        WHEN i.tinhChuDong = N'Trung bình' THEN 70
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.lamViecNhom = N'Tốt' THEN 100
                        WHEN i.lamViecNhom = N'Khá' THEN 80
                        WHEN i.lamViecNhom = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.tonTrong = N'Tốt' THEN 100
                        WHEN i.tonTrong = N'Khá' THEN 80
                        WHEN i.tonTrong = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.05) >= 90 THEN N'Xuất sắc'
                WHEN (i.tyLeThamGia * 0.2 + 
                     (CASE 
                        WHEN i.mucDoTapTrung = N'Xuất sắc' THEN 100
                        WHEN i.mucDoTapTrung = N'Tốt' THEN 85
                        WHEN i.mucDoTapTrung = N'Khá' THEN 70
                        WHEN i.mucDoTapTrung = N'Trung bình' THEN 50
                        ELSE 30
                     END) * 0.2 + 
                    i.hoanThanhBaiTap * 0.2 + 
                    i.thamGiaThaoLuan * 10 * 0.15 + 
                    (CASE
                        WHEN i.tinhChuDong = N'Chủ động' THEN 100
                        WHEN i.tinhChuDong = N'Trung bình' THEN 70
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.lamViecNhom = N'Tốt' THEN 100
                        WHEN i.lamViecNhom = N'Khá' THEN 80
                        WHEN i.lamViecNhom = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.tonTrong = N'Tốt' THEN 100
                        WHEN i.tonTrong = N'Khá' THEN 80
                        WHEN i.tonTrong = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.05) >= 80 THEN N'Tốt'
                WHEN (i.tyLeThamGia * 0.2 + 
                     (CASE 
                        WHEN i.mucDoTapTrung = N'Xuất sắc' THEN 100
                        WHEN i.mucDoTapTrung = N'Tốt' THEN 85
                        WHEN i.mucDoTapTrung = N'Khá' THEN 70
                        WHEN i.mucDoTapTrung = N'Trung bình' THEN 50
                        ELSE 30
                     END) * 0.2 + 
                    i.hoanThanhBaiTap * 0.2 + 
                    i.thamGiaThaoLuan * 10 * 0.15 + 
                    (CASE
                        WHEN i.tinhChuDong = N'Chủ động' THEN 100
                        WHEN i.tinhChuDong = N'Trung bình' THEN 70
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.lamViecNhom = N'Tốt' THEN 100
                        WHEN i.lamViecNhom = N'Khá' THEN 80
                        WHEN i.lamViecNhom = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.tonTrong = N'Tốt' THEN 100
                        WHEN i.tonTrong = N'Khá' THEN 80
                        WHEN i.tonTrong = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.05) >= 65 THEN N'Khá'
                WHEN (i.tyLeThamGia * 0.2 + 
                     (CASE 
                        WHEN i.mucDoTapTrung = N'Xuất sắc' THEN 100
                        WHEN i.mucDoTapTrung = N'Tốt' THEN 85
                        WHEN i.mucDoTapTrung = N'Khá' THEN 70
                        WHEN i.mucDoTapTrung = N'Trung bình' THEN 50
                        ELSE 30
                     END) * 0.2 + 
                    i.hoanThanhBaiTap * 0.2 + 
                    i.thamGiaThaoLuan * 10 * 0.15 + 
                    (CASE
                        WHEN i.tinhChuDong = N'Chủ động' THEN 100
                        WHEN i.tinhChuDong = N'Trung bình' THEN 70
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.lamViecNhom = N'Tốt' THEN 100
                        WHEN i.lamViecNhom = N'Khá' THEN 80
                        WHEN i.lamViecNhom = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.tonTrong = N'Tốt' THEN 100
                        WHEN i.tonTrong = N'Khá' THEN 80
                        WHEN i.tonTrong = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.05) >= 50 THEN N'Trung bình'
                WHEN (i.tyLeThamGia * 0.2 + 
                     (CASE 
                        WHEN i.mucDoTapTrung = N'Xuất sắc' THEN 100
                        WHEN i.mucDoTapTrung = N'Tốt' THEN 85
                        WHEN i.mucDoTapTrung = N'Khá' THEN 70
                        WHEN i.mucDoTapTrung = N'Trung bình' THEN 50
                        ELSE 30
                     END) * 0.2 + 
                    i.hoanThanhBaiTap * 0.2 + 
                    i.thamGiaThaoLuan * 10 * 0.15 + 
                    (CASE
                        WHEN i.tinhChuDong = N'Chủ động' THEN 100
                        WHEN i.tinhChuDong = N'Trung bình' THEN 70
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.lamViecNhom = N'Tốt' THEN 100
                        WHEN i.lamViecNhom = N'Khá' THEN 80
                        WHEN i.lamViecNhom = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.1 +
                    (CASE
                        WHEN i.tonTrong = N'Tốt' THEN 100
                        WHEN i.tonTrong = N'Khá' THEN 80
                        WHEN i.tonTrong = N'Trung bình' THEN 60
                        ELSE 40
                     END) * 0.05) >= 30 THEN N'Yếu'
                ELSE N'Kém'
            END
    FROM DanhGiaThaiDoHocTap dght
    INNER JOIN inserted i ON dght.maDanhGia = i.maDanhGia;
END;
GO

-- Trigger cập nhật điểm rèn luyện từ đánh giá thái độ học tập
CREATE TRIGGER trg_CapNhat_DiemRenLuyen
ON DanhGiaThaiDoHocTap
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @maSinhVien VARCHAR(10), @hocKy VARCHAR(1), @namHoc VARCHAR(9);
    
    SELECT 
        @maSinhVien = i.maSinhVien,
        @hocKy = lhp.hocKy,
        @namHoc = lhp.namHoc
    FROM 
        inserted i
        JOIN LopHocPhan lhp ON i.maLHP = lhp.maLHP;
    
    IF EXISTS (
        SELECT 1 
        FROM DiemRenLuyen 
        WHERE maSinhVien = @maSinhVien AND hocKy = @hocKy AND namHoc = @namHoc
    )
    BEGIN
        UPDATE DiemRenLuyen
        SET diemCuoiCung = (
                SELECT AVG(diemTongHop)
                FROM DanhGiaThaiDoHocTap dght
                JOIN LopHocPhan lhp ON dght.maLHP = lhp.maLHP
                WHERE dght.maSinhVien = @maSinhVien
                AND lhp.hocKy = @hocKy
                AND lhp.namHoc = @namHoc
            ),
            xepLoai = (
                CASE 
                    WHEN (SELECT AVG(diemTongHop)
                          FROM DanhGiaThaiDoHocTap dght
                          JOIN LopHocPhan lhp ON dght.maLHP = lhp.maLHP
                          WHERE dght.maSinhVien = @maSinhVien
                          AND lhp.hocKy = @hocKy
                          AND lhp.namHoc = @namHoc) >= 90 THEN N'Xuất sắc'
                    WHEN (SELECT AVG(diemTongHop)
                          FROM DanhGiaThaiDoHocTap dght
                          JOIN LopHocPhan lhp ON dght.maLHP = lhp.maLHP
                          WHERE dght.maSinhVien = @maSinhVien
                          AND lhp.hocKy = @hocKy
                          AND lhp.namHoc = @namHoc) >= 80 THEN N'Tốt'
                    WHEN (SELECT AVG(diemTongHop)
                          FROM DanhGiaThaiDoHocTap dght
                          JOIN LopHocPhan lhp ON dght.maLHP = lhp.maLHP
                          WHERE dght.maSinhVien = @maSinhVien
                          AND lhp.hocKy = @hocKy
                          AND lhp.namHoc = @namHoc) >= 70 THEN N'Khá'
                    WHEN (SELECT AVG(diemTongHop)
                          FROM DanhGiaThaiDoHocTap dght
                          JOIN LopHocPhan lhp ON dght.maLHP = lhp.maLHP
                          WHERE dght.maSinhVien = @maSinhVien
                          AND lhp.hocKy = @hocKy
                          AND lhp.namHoc = @namHoc) >= 50 THEN N'Trung bình'
                    WHEN (SELECT AVG(diemTongHop)
                          FROM DanhGiaThaiDoHocTap dght
                          JOIN LopHocPhan lhp ON dght.maLHP = lhp.maLHP
                          WHERE dght.maSinhVien = @maSinhVien
                          AND lhp.hocKy = @hocKy
                          AND lhp.namHoc = @namHoc) >= 30 THEN N'Yếu'
                    ELSE N'Kém'
                END
            )
        WHERE maSinhVien = @maSinhVien AND hocKy = @hocKy AND namHoc = @namHoc;
    END;
END;
GO

-- Trigger tự động điều chỉnh điểm rèn luyện sau khi có vi phạm kỷ luật
CREATE TRIGGER trg_CapNhat_DiemRenLuyen_ViPham
ON ViPhamKyLuat
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @maSinhVien VARCHAR(10), @hocKy VARCHAR(1), @namHoc VARCHAR(9), @diemTru INT;
    
    SELECT 
        @maSinhVien = i.maSinhVien,
        @diemTru = i.diemTru
    FROM 
        inserted i;
        
    IF EXISTS (SELECT 1 FROM inserted i WHERE i.maLHP IS NOT NULL)
    BEGIN
        SELECT 
            @hocKy = lhp.hocKy,
            @namHoc = lhp.namHoc
        FROM 
            inserted i
            JOIN LopHocPhan lhp ON i.maLHP = lhp.maLHP;
    END
    ELSE
    BEGIN
        SET @hocKy = CASE 
                        WHEN MONTH(GETDATE()) BETWEEN 1 AND 5 THEN '2'
                        WHEN MONTH(GETDATE()) BETWEEN 6 AND 7 THEN N'Hè'
                        ELSE '1'
                      END;
        SET @namHoc = CASE
                        WHEN MONTH(GETDATE()) >= 8 THEN 
                            CAST(YEAR(GETDATE()) AS VARCHAR) + '-' + CAST(YEAR(GETDATE()) + 1 AS VARCHAR)
                        ELSE
                            CAST(YEAR(GETDATE()) - 1 AS VARCHAR) + '-' + CAST(YEAR(GETDATE()) AS VARCHAR)
                      END;
    END;
    
    IF @hocKy = N'Hè' SET @hocKy = '2';
    
    IF EXISTS (
        SELECT 1 
        FROM DiemRenLuyen 
        WHERE maSinhVien = @maSinhVien AND hocKy = @hocKy AND namHoc = @namHoc
    )
    BEGIN
        UPDATE DiemRenLuyen
        SET diemCuoiCung = diemCuoiCung - @diemTru,
            xepLoai = CASE 
                        WHEN (diemCuoiCung - @diemTru) >= 90 THEN N'Xuất sắc'
                        WHEN (diemCuoiCung - @diemTru) >= 80 THEN N'Tốt'
                        WHEN (diemCuoiCung - @diemTru) >= 70 THEN N'Khá'
                        WHEN (diemCuoiCung - @diemTru) >= 50 THEN N'Trung bình'
                        WHEN (diemCuoiCung - @diemTru) >= 30 THEN N'Yếu'
                        ELSE N'Kém'
                      END
        WHERE maSinhVien = @maSinhVien AND hocKy = @hocKy AND namHoc = @namHoc;
        
        UPDATE DiemRenLuyen
        SET diemCuoiCung = 0
        WHERE diemCuoiCung < 0 AND maSinhVien = @maSinhVien AND hocKy = @hocKy AND namHoc = @namHoc;
    END;
END;
GO

-- Trigger cập nhật tỷ lệ tham gia từ điểm danh
CREATE TRIGGER trg_CapNhat_TyLeThamGia
ON DiemDanh
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @SinhVienLHPToUpdate TABLE (
        maSinhVien VARCHAR(10),
        maLHP VARCHAR(20)
    );
    
    INSERT INTO @SinhVienLHPToUpdate
    SELECT DISTINCT i.maSinhVien, bh.maLHP
    FROM inserted i
    JOIN BuoiHoc bh ON i.maBuoi = bh.maBuoi;
    
    INSERT INTO @SinhVienLHPToUpdate
    SELECT DISTINCT d.maSinhVien, bh.maLHP
    FROM deleted d
    JOIN BuoiHoc bh ON d.maBuoi = bh.maBuoi;
    
    UPDATE dght
    SET tyLeThamGia = (
            SELECT CASE 
                    WHEN COUNT(*) = 0 THEN 0
                    ELSE ROUND(
                        (SUM(CASE WHEN dd.trangThai IN (N'Có mặt', N'Đi muộn') THEN 1.0 ELSE 0 END) * 100.0) / 
                        COUNT(*), 
                        2
                    )
                  END
            FROM DiemDanh dd
            JOIN BuoiHoc bh ON dd.maBuoi = bh.maBuoi
            WHERE bh.maLHP = dght.maLHP
            AND dd.maSinhVien = dght.maSinhVien
        )
    FROM DanhGiaThaiDoHocTap dght
    INNER JOIN @SinhVienLHPToUpdate upd 
        ON dght.maSinhVien = upd.maSinhVien 
        AND dght.maLHP = upd.maLHP;
END;
GO

-- Trigger kiểm tra sinh viên đã đăng ký học phần trước khi điểm danh
CREATE TRIGGER trg_KiemTra_DiemDanh_DangKy
ON DiemDanh
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BuoiHoc bh ON i.maBuoi = bh.maBuoi
        WHERE NOT EXISTS (
            SELECT 1
            FROM DangKyHocPhan dkhp
            WHERE dkhp.maSinhVien = i.maSinhVien
            AND dkhp.maLHP = bh.maLHP
            AND dkhp.trangThai != N'Đã hủy'
        )
    )
    BEGIN
        RAISERROR (N'Sinh viên chưa đăng ký học phần này nên không thể điểm danh.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger kiểm tra dữ liệu hợp lệ trong đánh giá thái độ học tập
CREATE TRIGGER trg_KiemTra_DuLieu_ThaiDoHocTap
ON DanhGiaThaiDoHocTap
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE tyLeThamGia < 0 OR tyLeThamGia > 100
    )
    BEGIN
        RAISERROR (N'Tỷ lệ tham gia phải nằm trong khoảng từ 0 đến 100 phần trăm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE mucDoTapTrung NOT IN (N'Kém', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc')
    )
    BEGIN
        RAISERROR (N'Mức độ tập trung phải là Kém, Trung bình, Khá, Tốt hoặc Xuất sắc.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE hoanThanhBaiTap < 0 OR hoanThanhBaiTap > 100
    )
    BEGIN
        RAISERROR (N'Tỷ lệ hoàn thành bài tập phải nằm trong khoảng từ 0 đến 100 phần trăm.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE thamGiaThaoLuan < 0 OR thamGiaThaoLuan > 10
    )
    BEGIN
        RAISERROR (N'Điểm tham gia thảo luận phải nằm trong khoảng từ 0 đến 10.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE tinhChuDong NOT IN (N'Thụ động', N'Trung bình', N'Chủ động')
    )
    BEGIN
        RAISERROR (N'Tính chủ động phải là Thụ động, Trung bình hoặc Chủ động.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE lamViecNhom NOT IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')
    )
    BEGIN
        RAISERROR (N'Làm việc nhóm phải là Kém, Trung bình, Khá hoặc Tốt.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
    
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE tonTrong NOT IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')
    )
    BEGIN
        RAISERROR (N'Tôn trọng phải là Kém, Trung bình, Khá hoặc Tốt.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
SELECT * FROM Khoa;
SELECT * FROM NganhHoc;
SELECT * FROM GiangVien;
SELECT * FROM Lop;
SELECT * FROM SinhVien;
SELECT * FROM MonHoc;
SELECT * FROM TieuChiDanhGia;
SELECT * FROM LopHocPhan;
SELECT * FROM DangKyHocPhan;
SELECT * FROM BuoiHoc;
SELECT * FROM DiemDanh;
SELECT * FROM DanhGiaThaiDoHocTap;
SELECT * FROM ViPhamKyLuat;
SELECT * FROM DiemRenLuyen;
SELECT * FROM ChiTietDanhGia;
-- Xóa dữ liệu cũ để đảm bảo đồng bộ
DELETE FROM ChiTietDanhGia;
DELETE FROM DiemRenLuyen;
DELETE FROM ViPhamKyLuat;
DELETE FROM DanhGiaThaiDoHocTap;
DELETE FROM DiemDanh;
DELETE FROM BuoiHoc;
DELETE FROM DangKyHocPhan;
DELETE FROM LopHocPhan;
DELETE FROM TieuChiDanhGia;
DELETE FROM MonHoc;
DELETE FROM SinhVien;
DELETE FROM Lop;
DELETE FROM GiangVien;
DELETE FROM NganhHoc;
DELETE FROM Khoa;

-- Thêm dữ liệu vào bảng Khoa
INSERT INTO Khoa (maKhoa, tenKhoa, truongKhoa, moTa) VALUES
('K01', N'Công trình', N'Nguyễn Văn Hùng', N'Khoa chuyên về kỹ thuật xây dựng và giao thông'),
('K02', N'Vận tải - Kinh tế', N'Trần Thị B', N'Khoa đào tạo kinh tế và quản lý vận tải'),
('K03', N'Cơ khí - Công nghệ', N'Lê Văn C', N'Khoa chuyên về cơ khí và công nghệ'),
('K04', N'Công nghệ Thông tin', N'Phạm Thị D', N'Khoa đào tạo công nghệ thông tin'),
('K05', N'Khoa học Cơ bản', N'Hoàng Văn E', N'Khoa đào tạo các môn cơ bản'),
('K06', N'Điện - Điện tử', N'Nguyễn Văn F', N'Khoa đào tạo kỹ thuật điện và điện tử'),
('K07', N'Môi trường và An toàn', N'Trần Văn G', N'Khoa đào tạo kỹ thuật môi trường và an toàn lao động');

-- Thêm dữ liệu vào bảng NganhHoc
INSERT INTO NganhHoc (maNganh, tenNganh, maKhoa, moTa) VALUES
('N01', N'Kỹ thuật xây dựng công trình giao thông', 'K01', N'Ngành đào tạo kỹ sư xây dựng giao thông'),
('N02', N'Quản trị kinh doanh', 'K02', N'Ngành đào tạo quản trị doanh nghiệp'),
('N03', N'Công nghệ thông tin', 'K04', N'Ngành đào tạo chuyên gia công nghệ thông tin'),
('N04', N'Kỹ thuật ô tô', 'K03', N'Ngành đào tạo kỹ sư ô tô'),
('N05', N'Logistics và Quản lý chuỗi cung ứng', 'K02', N'Ngành đào tạo logistics'),
('N06', N'Kỹ thuật điện tử - viễn thông', 'K06', N'Ngành đào tạo kỹ sư điện tử và viễn thông'),
('N07', N'Kỹ thuật môi trường', 'K07', N'Ngành đào tạo kỹ sư môi trường và quản lý tài nguyên');

-- Thêm dữ liệu vào bảng GiangVien
INSERT INTO GiangVien (maGiangVien, hoTen, gioiTinh, email, soDienThoai, maKhoa, chucVu) VALUES
('GV01', N'Nguyễn Văn Hùng', N'Nam', 'hungnv@utc2.edu.vn', '0912345678', 'K01', N'Trưởng khoa'),
('GV02', N'Trần Thị Mai', N'Nữ', 'mai.tt@utc2.edu.vn', '0987654321', 'K02', N'Phó khoa'),
('GV03', N'Lê Văn Tuấn', N'Nam', 'tuanlv@utc2.edu.vn', '0901234567', 'K03', N'Giảng viên'),
('GV04', N'Phạm Thị Lan', N'Nữ', 'lanpt@utc2.edu.vn', '0978123456', 'K04', N'Giảng viên chính'),
('GV05', N'Hoàng Văn Nam', N'Nam', 'namhv@utc2.edu.vn', '0932123456', 'K05', N'Giảng viên'),
('GV06', N'Đỗ Thị Hà', N'Nữ', 'hado@utc2.edu.vn', '0918765432', 'K01', N'Giảng viên'),
('GV07', N'Vũ Văn Long', N'Nam', 'longvv@utc2.edu.vn', '0981234567', 'K02', N'Giảng viên'),
('GV08', N'Nguyễn Thị Hoa', N'Nữ', 'hoant@utc2.edu.vn', '0967891234', 'K03', N'Phó khoa'),
('GV09', N'Nguyễn Văn Minh', N'Nam', 'minhnv@utc2.edu.vn', '0923456789', 'K06', N'Giảng viên'),
('GV10', N'Trần Thị Thảo', N'Nữ', 'thaott@utc2.edu.vn', '0945678901', 'K06', N'Phó khoa'),
('GV11', N'Lê Văn Hòa', N'Nam', 'hoalv@utc2.edu.vn', '0934567890', 'K07', N'Giảng viên chính'),
('GV12', N'Phạm Thị Ngọc', N'Nữ', 'ngocpt@utc2.edu.vn', '0916789012', 'K07', N'Giảng viên');

-- Thêm dữ liệu vào bảng Lop
INSERT INTO Lop (maLop, tenLop, maKhoa, maNganh, maGVCN, namBatDau) VALUES
('L01', N'KXDG01', 'K01', 'N01', 'GV01', 2023),
('L02', N'QTKD01', 'K02', 'N02', 'GV02', 2023),
('L03', N'CNTT01', 'K04', 'N03', 'GV04', 2023),
('L04', N'KTO01', 'K03', 'N04', 'GV03', 2023),
('L05', N'LOG01', 'K02', 'N05', 'GV07', 2023),
('L06', N'DTVT01', 'K06', 'N06', 'GV09', 2024),
('L07', N'KTMT01', 'K07', 'N07', 'GV11', 2024);

-- Thêm dữ liệu vào bảng SinhVien
INSERT INTO SinhVien (maSinhVien, hoTen, ngaySinh, gioiTinh, email, soDienThoai, diaChi, CCCD, maLop, maNganh, maKhoa, namNhapHoc, trangThai) VALUES
('SV001', N'Nguyễn Văn Nam', '2003-05-10', N'Nam', 'namnv001@utc2.edu.vn', '0912345679', N'TP.HCM', '123456789001', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV002', N'Lê Thị Hồng', '2003-07-15', N'Nữ', 'honglt002@utc2.edu.vn', '0987654322', N'Bình Dương', '987654321002', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV003', N'Trần Văn Hùng', '2002-03-22', N'Nam', 'hungtv003@utc2.edu.vn', '0901234568', N'Đồng Nai', '123456789003', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV004', N'Phạm Thị Mai', '2003-11-30', N'Nữ', 'maipt004@utc2.edu.vn', '0978123457', N'TP.HCM', '987654321004', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV005', N'Hoàng Văn Tâm', '2002-09-05', N'Nam', 'tamhv005@utc2.edu.vn', '0932123457', N'Long An', '123456789005', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV006', N'Nguyễn Thị Lan', '2003-01-12', N'Nữ', 'lannt006@utc2.edu.vn', '0918765433', N'TP.HCM', '987654321006', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV007', N'Vũ Văn Long', '2002-06-18', N'Nam', 'longvv007@utc2.edu.vn', '0981234568', N'Bình Phước', '123456789007', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV008', N'Trần Thị Hoa', '2003-04-25', N'Nữ', 'hoatt008@utc2.edu.vn', '0967891235', N'TP.HCM', '987654321008', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV009', N'Nguyễn Văn An', '2003-05-10', N'Nam', 'annv009@utc2.edu.vn', '0912345681', N'TP.HCM', '123456789009', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV010', N'Trần Thị Bình', '2003-07-15', N'Nữ', 'binhtt010@utc2.edu.vn', '0987654325', N'Bình Dương', '987654321010', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV011', N'Lê Văn Cường', '2002-03-22', N'Nam', 'cuonglv011@utc2.edu.vn', '0901234571', N'Đồng Nai', '123456789011', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV012', N'Phạm Thị Duyên', '2003-11-30', N'Nữ', 'duyenpt012@utc2.edu.vn', '0978123460', N'TP.HCM', '987654321012', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV013', N'Hoàng Văn Em', '2002-09-05', N'Nam', 'emhv013@utc2.edu.vn', '0932123460', N'Long An', '123456789013', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV014', N'Nguyễn Thị Phượng', '2003-01-12', N'Nữ', 'phuongnt014@utc2.edu.vn', '0918765434', N'TP.HCM', '987654321014', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV015', N'Vũ Văn Khánh', '2002-06-18', N'Nam', 'khanhvv015@utc2.edu.vn', '0981234569', N'Bình Phước', '123456789015', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV016', N'Trần Thị Ngọc', '2003-04-25', N'Nữ', 'ngoctt016@utc2.edu.vn', '0967891236', N'TP.HCM', '987654321016', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV017', N'Nguyễn Văn Bình', '2003-10-03', N'Nam', 'binhnv017@utc2.edu.vn', '0919876544', 'Tiền Giang', '123456789017', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV018', N'Trần Thị Ngọc', '2002-12-19', N'Nữ', 'ngoctt018@utc2.edu.vn', '0984561238', N'TP.HCM', '987654321018', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV019', N'Lê Văn Đức', '2003-05-07', N'Nam', 'duclv019@utc2.edu.vn', '0936789013', 'Bình Dương', '123456789019', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV020', N'Phạm Thị Thu', '2002-07-23', N'Nữ', 'thupt020@utc2.edu.vn', '0971234569', 'TP.HCM', '987654321020', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV021', N'Hoàng Văn Anh', '2003-03-15', N'Nam', 'anhhv021@utc2.edu.vn', '0947891235', 'Đồng Nai', '123456789021', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV022', N'Nguyễn Thị Hạnh', '2003-01-12', N'Nữ', 'hanhnt022@utc2.edu.vn', '0918765435', N'TP.HCM', '987654321022', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV023', N'Vũ Văn Hùng', '2002-06-18', N'Nam', 'hungvv023@utc2.edu.vn', '0981234570', N'Bình Phước', '123456789023', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV024', N'Trần Thị Lan', '2003-04-25', N'Nữ', 'lantt024@utc2.edu.vn', '0967891237', N'TP.HCM', '987654321024', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV025', N'Nguyễn Văn Hùng', '2004-01-10', N'Nam', 'hungnv025@utc2.edu.vn', '0913456790', 'TP.HCM', '123456789025', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV026', N'Trần Thị Lan', '2004-06-22', N'Nữ', 'lantt026@utc2.edu.vn', '0989012346', 'Long An', '987654321026', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV027', N'Lê Văn Tâm', '2004-09-08', N'Nam', 'tamhv027@utc2.edu.vn', '0961237891', 'TP.HCM', '123456789027', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV028', N'Phạm Thị Hồng', '2004-02-14', N'Nữ', 'hongpt028@utc2.edu.vn', '0926789013', 'Bình Dương', '987654321028', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV029', N'Hoàng Văn Sơn', '2004-11-27', N'Nam', 'sonhv029@utc2.edu.vn', '0951234568', 'TP.HCM', '123456789029', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV030', N'Nguyễn Thị Mai', '2003-08-16', N'Nữ', 'maint030@utc2.edu.vn', '0912345680', 'Đồng Nai', '987654321030', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV031', N'Trần Văn Long', '2003-04-29', N'Nam', 'longtv031@utc2.edu.vn', '0987654323', 'TP.HCM', '123456789031', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV032', N'Lê Thị Hoa', '2003-12-05', N'Nữ', 'hoalt032@utc2.edu.vn', '0901234569', 'Bình Phước', '987654321032', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV033', N'Nguyễn Thị Mai', '2003-08-16', N'Nữ', 'maint033@utc2.edu.vn', '0912345681', 'Đồng Nai', '987654321033', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV034', N'Trần Văn Long', '2003-04-29', N'Nam', 'longtv034@utc2.edu.vn', '0987654324', 'TP.HCM', '123456789034', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV035', N'Lê Thị Hoa', '2003-12-05', N'Nữ', 'hoalt035@utc2.edu.vn', '0901234570', 'Bình Phước', '987654321035', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV036', N'Phạm Văn Khánh', '2003-06-11', N'Nam', 'khanhpv036@utc2.edu.vn', '0978123459', 'TP.HCM', '123456789036', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV037', N'Hoàng Thị Minh', '2003-02-17', N'Nữ', 'minhht037@utc2.edu.vn', '0932123460', 'Long An', '987654321037', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV038', N'Nguyễn Văn Phúc', '2003-01-12', N'Nam', 'phucnv038@utc2.edu.vn', '0918765436', 'TP.HCM', '123456789038', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV039', N'Trần Thị Ngọc', '2003-04-25', N'Nữ', 'ngoctt039@utc2.edu.vn', '0967891238', 'Bình Dương', '987654321039', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV040', N'Lê Văn Hùng', '2003-10-03', N'Nam', 'hunglv040@utc2.edu.vn', '0919876545', 'Tiền Giang', '123456789040', 'L05', 'N05', 'K02', 2023, N'Bảo lưu'),
('SV041', N'Nguyễn Văn Khôi', '2004-03-15', N'Nam', 'khoinv041@utc2.edu.vn', '0913456781', N'TP.HCM', '123456789041', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV042', N'Trần Thị Thùy', '2004-05-20', N'Nữ', 'thuytt042@utc2.edu.vn', '0989012347', N'Bình Dương', '987654321042', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV043', N'Lê Văn Tài', '2003-07-10', N'Nam', 'tailv043@utc2.edu.vn', '0961237892', N'Đồng Nai', '123456789043', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV044', N'Phạm Thị Linh', '2004-09-25', N'Nữ', 'linhpt044@utc2.edu.vn', '0926789014', N'TP.HCM', '987654321044', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV045', N'Hoàng Văn Quang', '2004-11-12', N'Nam', 'quanghv045@utc2.edu.vn', '0951234569', N'Long An', '123456789045', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV046', N'Nguyễn Thị Hương', '2003-02-18', N'Nữ', 'huongnt046@utc2.edu.vn', '0912345682', N'TP.HCM', '987654321046', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV047', N'Trần Văn Đạt', '2003-04-30', N'Nam', 'dattv047@utc2.edu.vn', '0987654326', N'Bình Phước', '123456789047', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV048', N'Lê Thị Ánh', '2003-06-22', N'Nữ', 'anhtt048@utc2.edu.vn', '0901234572', N'TP.HCM', '987654321048', 'L06', 'N06', 'K06', 2024, N'Đang học'),
('SV049', N'Nguyễn Văn Duy', '2004-01-05', N'Nam', 'duynv049@utc2.edu.vn', '0919876546', N'Tiền Giang', '123456789049', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV050', N'Trần Thị Kim', '2004-08-14', N'Nữ', 'kimtt050@utc2.edu.vn', '0984561239', N'TP.HCM', '987654321050', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV051', N'Lê Văn Phước', '2003-10-20', N'Nam', 'phuoclv051@utc2.edu.vn', '0936789014', N'Bình Dương', '123456789051', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV052', N'Phạm Thị Nhung', '2004-12-01', N'Nữ', 'nhungpt052@utc2.edu.vn', '0971234570', N'TP.HCM', '987654321052', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV053', N'Hoàng Văn Bảo', '2003-03-09', N'Nam', 'baohv053@utc2.edu.vn', '0947891236', N'Đồng Nai', '123456789053', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV054', N'Nguyễn Thị Oanh', '2004-05-17', N'Nữ', 'oanhnt054@utc2.edu.vn', '0918765437', N'TP.HCM', '987654321054', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV055', N'Trần Văn Kiên', '2003-07-28', N'Nam', 'kientv055@utc2.edu.vn', '0981234571', N'Bình Phước', '123456789055', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV056', N'Lê Thị Duyên', '2004-09-03', N'Nữ', 'duyentt056@utc2.edu.vn', '0967891239', N'TP.HCM', '987654321056', 'L07', 'N07', 'K07', 2024, N'Đang học'),
('SV057', N'Nguyễn Văn Thành', '2003-11-15', N'Nam', 'thanhnv057@utc2.edu.vn', '0912345683', N'TP.HCM', '123456789057', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV058', N'Trần Thị Hằng', '2003-01-27', N'Nữ', 'hangtt058@utc2.edu.vn', '0987654327', N'Long An', '987654321058', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV059', N'Lê Văn Tín', '2004-04-10', N'Nam', 'tinlv059@utc2.edu.vn', '0901234573', N'TP.HCM', '123456789059', 'L03', 'N03', 'K04', 2024, N'Đang học'),
('SV060', N'Phạm Thị Yến', '2003-06-05', N'Nữ', 'yenpt060@utc2.edu.vn', '0978123461', N'Bình Dương', '987654321060', 'L05', 'N05', 'K02', 2023, N'Đang học');

-- Thêm dữ liệu vào bảng MonHoc
INSERT INTO MonHoc (maMonHoc, tenMonHoc, soTinChi, maKhoa, moTa) VALUES
('MH01', N'Kỹ thuật xây dựng', 3, 'K01', N'Môn học về kỹ thuật xây dựng công trình giao thông'),
('MH02', N'Quản trị marketing', 3, 'K02', N'Môn học về chiến lược marketing'),
('MH03', N'Lập trình Java', 3, 'K04', N'Môn học về lập trình Java cơ bản'),
('MH04', N'Công nghệ ô tô', 3, 'K03', N'Môn học về công nghệ và bảo trì ô tô'),
('MH05', N'Quản lý chuỗi cung ứng', 3, 'K02', N'Môn học về logistics và chuỗi cung ứng'),
('MH06', N'Toán cao cấp', 3, 'K05', N'Môn học cơ bản về toán học'),
('MH07', N'Vật lý kỹ thuật', 3, 'K05', N'Môn học cơ bản về vật lý'),
('MH08', N'Mạch điện tử', 3, 'K06', N'Môn học về thiết kế và phân tích mạch điện tử'),
('MH09', N'Quản lý chất thải', 3, 'K07', N'Môn học về xử lý và quản lý chất thải môi trường');

-- Thêm dữ liệu vào bảng TieuChiDanhGia
INSERT INTO TieuChiDanhGia (maTieuChi, tenTieuChi, loaiTieuChi, moTa, diemToiDa, trongSo) VALUES
('TC01', N'Tỷ lệ tham gia', N'Tham gia', N'Đánh giá mức độ tham gia buổi học', 100, 0.20),
('TC02', N'Mức độ tập trung', N'Tập trung', N'Đánh giá sự tập trung trong giờ học', 100, 0.20),
('TC03', N'Hoàn thành bài tập', N'Hoàn thành', N'Đánh giá tỷ lệ hoàn thành bài tập', 100, 0.20),
('TC04', N'Tham gia thảo luận', N'Thảo luận', N'Đánh giá mức độ tham gia thảo luận', 10, 0.15),
('TC05', N'Tính chủ động', N'Chủ động', N'Đánh giá sự chủ động trong học tập', 100, 0.10),
('TC06', N'Làm việc nhóm', N'Làm việc nhóm', N'Đánh giá khả năng làm việc nhóm', 100, 0.10),
('TC07', N'Tôn trọng', N'Tôn trọng', N'Đánh giá thái độ tôn trọng', 100, 0.05),
('TC08', N'Kỷ luật', N'Kỷ luật', N'Đánh giá tuân thủ kỷ luật', 100, 0.05);

-- Thêm dữ liệu vào bảng LopHocPhan
INSERT INTO LopHocPhan (maLHP, maMonHoc, maGiangVien, hocKy, namHoc, siSoToiDa, soSinhVienHienTai, ngayBatDau, ngayKetThuc) VALUES
('LHP01', 'MH01', 'GV01', '1', '2023-2024', 60, 8, '2023-09-01', '2023-12-15'),
('LHP02', 'MH02', 'GV02', '1', '2023-2024', 60, 8, '2023-09-01', '2023-12-15'),
('LHP03', 'MH03', 'GV04', '1', '2023-2024', 60, 8, '2023-09-01', '2023-12-15'),
('LHP04', 'MH04', 'GV03', '2', '2023-2024', 60, 8, '2024-02-01', '2024-05-15'),
('LHP05', 'MH05', 'GV07', '2', '2023-2024', 60, 8, '2024-02-01', '2024-05-15'),
('LHP06', 'MH06', 'GV05', '1', '2024-2025', 60, 8, '2024-09-01', '2024-12-15'),
('LHP07', 'MH07', 'GV05', '2', '2024-2025', 60, 8, '2025-02-01', '2025-05-15'),
('LHP08', 'MH08', 'GV09', '1', '2024-2025', 60, 8, '2024-09-01', '2024-12-15'),
('LHP09', 'MH09', 'GV11', '1', '2024-2025', 60, 8, '2024-09-01', '2024-12-15'),
('LHP10', 'MH03', 'GV04', '2', '2024-2025', 60, 8, '2025-02-01', '2025-05-15'),
('LHP11', 'MH01', 'GV01', '2', '2024-2025', 60, 8, '2025-02-01', '2025-05-15');

-- Thêm dữ liệu vào bảng DangKyHocPhan
INSERT INTO DangKyHocPhan (maSinhVien, maLHP, ngayDangKy, trangThai, diemGiuaKy, diemCuoiKy, diemThucHanh, diemTong) VALUES
-- Trạng thái Hoàn thành
('SV001', 'LHP01', '2023-08-20', N'Hoàn thành', 5.0, 4.5, 5.5, 5.0),
('SV002', 'LHP01', '2023-08-20', N'Hoàn thành', 7.5, 7.0, 8.0, 7.5),
('SV003', 'LHP01', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV004', 'LHP01', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV005', 'LHP01', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV006', 'LHP01', '2023-08-20', N'Hoàn thành', 6.5, 6.0, 7.0, 6.5),
('SV007', 'LHP01', '2023-08-20', N'Hoàn thành', 9.0, 9.5, 9.0, 9.2),
('SV008', 'LHP01', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 8.5, 8.3),
('SV009', 'LHP02', '2023-08-20', N'Hoàn thành', 4.5, 5.0, 4.0, 4.5),
('SV010', 'LHP02', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 7.5, 7.5),
('SV011', 'LHP02', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV012', 'LHP02', '2023-08-20', N'Hoàn thành', 7.0, 7.0, 7.5, 7.2),
('SV013', 'LHP02', '2023-08-20', N'Hoàn thành', 8.5, 8.5, 8.0, 8.3),
('SV014', 'LHP02', '2023-08-20', N'Hoàn thành', 6.0, 6.5, 7.0, 6.5),
('SV015', 'LHP02', '2023-08-20', N'Hoàn thành', 9.0, 9.0, 9.0, 9.0),
('SV016', 'LHP02', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV017', 'LHP03', '2023-08-20', N'Hoàn thành', 5.5, 5.0, 4.5, 5.0),
('SV018', 'LHP03', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 8.0, 7.7),
('SV019', 'LHP03', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV020', 'LHP03', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV021', 'LHP03', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV022', 'LHP03', '2023-08-20', N'Hoàn thành', 6.5, 6.0, 7.0, 6.5),
('SV023', 'LHP03', '2023-08-20', N'Hoàn thành', 9.0, 9.5, 9.0, 9.2),
('SV024', 'LHP03', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 8.5, 8.3),
('SV025', 'LHP04', '2024-01-20', N'Hoàn thành', 8.0, 8.5, 7.5, 8.2),
('SV026', 'LHP04', '2024-01-20', N'Hoàn thành', 7.5, 7.0, 8.0, 7.5),
('SV027', 'LHP04', '2024-01-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV028', 'LHP04', '2024-01-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV029', 'LHP04', '2024-01-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV030', 'LHP04', '2024-01-20', N'Hoàn thành', 6.0, 6.5, 7.0, 6.5),
('SV031', 'LHP04', '2024-01-20', N'Hoàn thành', 9.0, 9.0, 9.0, 9.0),
('SV032', 'LHP04', '2024-01-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV033', 'LHP05', '2024-01-20', N'Hoàn thành', 8.5, 8.0, 8.0, 8.2),
('SV034', 'LHP05', '2024-01-20', N'Hoàn thành', 7.5, 7.5, 7.5, 7.5),
('SV035', 'LHP05', '2024-01-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV036', 'LHP05', '2024-01-20', N'Hoàn thành', 7.0, 7.0, 7.5, 7.2),
('SV037', 'LHP05', '2024-01-20', N'Hoàn thành', 8.5, 8.5, 8.0, 8.3),
('SV038', 'LHP05', '2024-01-20', N'Hoàn thành', 6.0, 6.5, 7.0, 6.5),
('SV039', 'LHP05', '2024-01-20', N'Hoàn thành', 9.0, 9.0, 9.0, 9.0),
('SV040', 'LHP05', '2024-01-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
-- Trạng thái Đang học
('SV001', 'LHP06', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV002', 'LHP07', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL),
('SV003', 'LHP06', '2024-08-20', N'Đang học', 8.5, NULL, 7.0, NULL),
('SV004', 'LHP07', '2024-08-20', N'Đang học', 7.0, NULL, 8.5, NULL),
('SV005', 'LHP06', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV006', 'LHP07', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV007', 'LHP06', '2024-08-20', N'Đang học', 7.5, NULL, 7.5, NULL),
('SV008', 'LHP07', '2024-08-20', N'Đang học', 8.0, NULL, 8.0, NULL),
-- Trạng thái Đã hủy
('SV009', 'LHP06', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV010', 'LHP07', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV011', 'LHP06', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV012', 'LHP07', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV013', 'LHP06', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV014', 'LHP07', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV015', 'LHP06', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV016', 'LHP07', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
-- LHP08 (Mạch điện tử, học kỳ 1, 2024-2025)
('SV041', 'LHP08', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL),
('SV042', 'LHP08', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV043', 'LHP08', '2024-08-20', N'Đang học', 6.5, NULL, 7.0, NULL),
('SV044', 'LHP08', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV045', 'LHP08', '2024-08-20', N'Đang học', 7.0, NULL, 7.5, NULL),
('SV046', 'LHP08', '2024-08-20', N'Đang học', 9.0, NULL, 9.0, NULL),
('SV047', 'LHP08', '2024-08-20', N'Đang học', 8.0, NULL, 8.0, NULL),
('SV048', 'LHP08', '2024-08-20', N'Đang học', 7.5, NULL, 7.5, NULL),
-- LHP09 (Quản lý chất thải, học kỳ 1, 2024-2025)
('SV049', 'LHP09', '2024-08-20', N'Đang học', 8.0, NULL, 8.5, NULL),
('SV050', 'LHP09', '2024-08-20', N'Đang học', 7.5, NULL, 7.0, NULL),
('SV051', 'LHP09', '2024-08-20', N'Đang học', 6.5, NULL, 7.0, NULL),
('SV052', 'LHP09', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV053', 'LHP09', '2024-08-20', N'Đang học', 7.0, NULL, 7.5, NULL),
('SV054', 'LHP09', '2024-08-20', N'Đang học', 9.0, NULL, 9.0, NULL),
('SV055', 'LHP09', '2024-08-20', N'Đang học', 8.0, NULL, 8.0, NULL),
('SV056', 'LHP09', '2024-08-20', N'Đang học', 7.5, NULL, 7.5, NULL),
-- LHP10 (Lập trình Java, học kỳ 2, 2024-2025)
('SV017', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV018', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV019', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV020', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV021', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV022', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV023', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV024', 'LHP10', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
-- LHP11 (Kỹ thuật xây dựng, học kỳ 2, 2024-2025)
('SV001', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV002', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV003', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV004', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV005', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV006', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV007', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
('SV008', 'LHP11', '2025-01-20', N'Đang học', NULL, NULL, NULL, NULL),
-- Đã hủy
('SV057', 'LHP08', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV058', 'LHP09', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV059', 'LHP10', '2025-01-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV060', 'LHP11', '2025-01-20', N'Đã hủy', NULL, NULL, NULL, NULL);

-- Thêm dữ liệu vào bảng BuoiHoc
INSERT INTO BuoiHoc (maLHP, ngayHoc, gioBatDau, gioKetThuc, phongHoc, chuDe, trangThai) VALUES
('LHP01', '2023-09-19', '07:30:00', '09:30:00', 'P101', N'Thiết kế nền móng', N'Đã diễn ra'),
('LHP01', '2023-09-26', '07:30:00', '09:30:00', 'P101', N'Vật liệu xây dựng', N'Đã diễn ra'),
('LHP02', '2023-09-20', '09:45:00', '11:45:00', 'P102', N'Nghiên cứu thị trường', N'Đã diễn ra'),
('LHP02', '2023-09-27', '09:45:00', '11:45:00', 'P102', N'Quảng cáo', N'Đã diễn ra'),
('LHP03', '2023-09-21', '13:30:00', '15:30:00', 'P103', N'Lập trình hướng đối tượng', N'Đã diễn ra'),
('LHP03', '2023-09-28', '13:30:00', '15:30:00', 'P103', N'Xử lý ngoại lệ', N'Đã diễn ra'),
('LHP04', '2024-02-19', '07:30:00', '09:30:00', 'P104', N'Hệ thống truyền động', N'Đã diễn ra'),
('LHP04', '2024-02-26', '07:30:00', '09:30:00', 'P104', N'Bảo trì ô tô', N'Đã diễn ra'),
('LHP05', '2024-02-20', '09:45:00', '11:45:00', 'P105', N'Vận tải logistics', N'Đã diễn ra'),
('LHP05', '2024-02-27', '09:45:00', '11:45:00', 'P105', N'Tối ưu hóa chuỗi cung ứng', N'Đã diễn ra'),
('LHP06', '2024-09-19', '07:30:00', '09:30:00', 'P106', N'Toán cao cấp - Ma trận', N'Chưa diễn ra'),
('LHP07', '2025-02-20', '09:45:00', '11:45:00', 'P107', N'Vật lý - Điện từ', N'Chưa diễn ra'),
('LHP08', '2024-09-25', '07:30:00', '09:30:00', 'P108', N'Nguyên lý mạch điện tử', N'Chưa diễn ra'),
('LHP08', '2024-10-02', '07:30:00', '09:30:00', 'P108', N'Thiết kế mạch số', N'Chưa diễn ra'),
('LHP09', '2024-09-26', '09:45:00', '11:45:00', 'P109', N'Xử lý nước thải', N'Chưa diễn ra'),
('LHP09', '2024-10-03', '09:45:00', '11:45:00', 'P109', N'Quản lý chất thải rắn', N'Chưa diễn ra'),
('LHP10', '2025-02-10', '13:30:00', '15:30:00', 'P110', N'Java nâng cao', N'Chưa diễn ra'),
('LHP10', '2025-02-17', '13:30:00', '15:30:00', 'P110', N'Lập trình giao diện', N'Chưa diễn ra'),
('LHP11', '2025-02-11', '07:30:00', '09:30:00', 'P111', N'Thiết kế cầu', N'Chưa diễn ra'),
('LHP11', '2025-02-18', '07:30:00', '09:30:00', 'P111', N'Kết cấu bê tông', N'Chưa diễn ra'),
('LHP08', '2024-09-18', '07:30:00', '09:30:00', 'P108', N'Giới thiệu mạch điện tử', N'Đã diễn ra'),
('LHP09', '2024-09-19', '09:45:00', '11:45:00', 'P109', N'Tổng quan quản lý chất thải', N'Đã diễn ra');

-- Thêm dữ liệu vào bảng DiemDanh
INSERT INTO DiemDanh (maSinhVien, maBuoi, trangThai, thoiGianGhi, ghiChu) VALUES
-- LHP01 (maBuoi 1, 2)
('SV001', 1, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV002', 1, N'Vắng mặt', '2023-09-19 07:30:00', N'Không có phép'),
('SV003', 1, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV004', 1, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV005', 1, N'Có phép', '2023-09-19 07:30:00', N'Xin nghỉ ốm'),
('SV006', 1, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV007', 1, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV008', 1, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV001', 2, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV002', 2, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV003', 2, N'Vắng mặt', '2023-09-26 07:30:00', N'Không có phép'),
('SV004', 2, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV005', 2, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV006', 2, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV007', 2, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV008', 2, N'Có mặt', '2023-09-26 07:30:00', NULL),
-- LHP02 (maBuoi 3, 4)
('SV009', 3, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV010', 3, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV011', 3, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV012', 3, N'Vắng mặt', '2023-09-20 09:45:00', N'Không có phép'),
('SV013', 3, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV014', 3, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV015', 3, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV016', 3, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV009', 4, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV010', 4, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV011', 4, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV012', 4, N'Có phép', '2023-09-27 09:45:00', N'Xin nghỉ gia đình'),
('SV013', 4, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV014', 4, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV015', 4, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV016', 4, N'Có mặt', '2023-09-27 09:45:00', NULL),
-- LHP03 (maBuoi 5, 6)
('SV017', 5, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV018', 5, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV019', 5, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV020', 5, N'Vắng mặt', '2023-09-21 13:30:00', N'Không có phép'),
('SV021', 5, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV022', 5, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV023', 5, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV024', 5, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV017', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV018', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV019', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV020', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV021', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV022', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV023', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV024', 6, N'Có mặt', '2023-09-28 13:30:00', NULL),
-- LHP04 (maBuoi 7, 8)
('SV025', 7, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV026', 7, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV027', 7, N'Vắng mặt', '2024-02-19 07:30:00', N'Không có phép'),
('SV028', 7, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV029', 7, N'Có phép', '2024-02-19 07:30:00', N'Xin nghỉ ốm'),
('SV030', 7, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV031', 7, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV032', 7, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV025', 8, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV026', 8, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV027', 8, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV028', 8, N'Vắng mặt', '2024-02-26 07:30:00', N'Không có phép'),
('SV029', 8, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV030', 8, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV031', 8, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV032', 8, N'Có mặt', '2024-02-26 07:30:00', NULL),
-- LHP05 (maBuoi 9, 10)
('SV033', 9, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV034', 9, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV035', 9, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV036', 9, N'Vắng mặt', '2024-02-20 09:45:00', N'Không có phép'),
('SV037', 9, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV038', 9, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV039', 9, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV040', 9, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV033', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV034', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV035', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV036', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV037', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV038', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV039', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV040', 10, N'Có mặt', '2024-02-27 09:45:00', NULL),
-- LHP08 (maBuoi 21)
('SV041', 21, N'Có mặt', '2024-09-18 07:30:00', NULL),
('SV042', 21, N'Có mặt', '2024-09-18 07:30:00', NULL),
('SV043', 21, N'Vắng mặt', '2024-09-18 07:30:00', N'Không có phép'),
('SV044', 21, N'Có mặt', '2024-09-18 07:30:00', NULL),
('SV045', 21, N'Có phép', '2024-09-18 07:30:00', N'Xin nghỉ ốm'),
('SV046', 21, N'Có mặt', '2024-09-18 07:30:00', NULL),
('SV047', 21, N'Có mặt', '2024-09-18 07:30:00', NULL),
('SV048', 21, N'Có mặt', '2024-09-18 07:30:00', NULL),
-- LHP09 (maBuoi 22)
('SV049', 22, N'Có mặt', '2024-09-19 09:45:00', NULL),
('SV050', 22, N'Có mặt', '2024-09-19 09:45:00', NULL),
('SV051', 22, N'Vắng mặt', '2024-09-19 09:45:00', N'Không có phép'),
('SV052', 22, N'Có mặt', '2024-09-19 09:45:00', NULL),
('SV053', 22, N'Có phép', '2024-09-19 09:45:00', N'Xin nghỉ gia đình'),
('SV054', 22, N'Có mặt', '2024-09-19 09:45:00', NULL),
('SV055', 22, N'Có mặt', '2024-09-19 09:45:00', NULL),
('SV056', 22, N'Có mặt', '2024-09-19 09:45:00', NULL);

-- Thêm dữ liệu vào bảng DanhGiaThaiDoHocTap
INSERT INTO DanhGiaThaiDoHocTap (maSinhVien, maLHP, ngayDanhGia, nguoiDanhGia, tyLeThamGia, mucDoTapTrung, hoanThanhBaiTap, thamGiaThaoLuan, tinhChuDong, lamViecNhom, tonTrong, ghiChu) VALUES
('SV001', 'LHP01', '2023-12-10', 'GV01', 40, N'Kém', 50, 3, N'Thụ động', N'Kém', N'Kém', N'Cần cải thiện'),
('SV002', 'LHP01', '2023-12-10', 'GV01', 55, N'Trung bình', 60, 4, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV003', 'LHP01', '2023-12-10', 'GV01', 70, N'Khá', 75, 6, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV004', 'LHP01', '2023-12-10', 'GV01', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV005', 'LHP01', '2023-12-10', 'GV01', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV006', 'LHP01', '2023-12-10', 'GV01', 60, N'Trung bình', 65, 5, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV007', 'LHP01', '2023-12-10', 'GV01', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV008', 'LHP01', '2023-12-10', 'GV01', 90, N'Xuất sắc', 95, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV009', 'LHP02', '2023-12-10', 'GV02', 45, N'Kém', 55, 3, N'Thụ động', N'Kém', N'Kém', N'Cần cải thiện'),
('SV010', 'LHP02', '2023-12-10', 'GV02', 60, N'Trung bình', 65, 5, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV011', 'LHP02', '2023-12-10', 'GV02', 75, N'Khá', 70, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV012', 'LHP02', '2023-12-10', 'GV02', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV013', 'LHP02', '2023-12-10', 'GV02', 90, N'Xuất sắc', 95, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV014', 'LHP02', '2023-12-10', 'GV02', 50, N'Trung bình', 60, 4, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV015', 'LHP02', '2023-12-10', 'GV02', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV016', 'LHP02', '2023-12-10', 'GV02', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV017', 'LHP03', '2023-12-10', 'GV04', 50, N'Trung bình', 60, 4, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV018', 'LHP03', '2023-12-10', 'GV04', 65, N'Khá', 70, 6, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV019', 'LHP03', '2023-12-10', 'GV04', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV020', 'LHP03', '2023-12-10', 'GV04', 85, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV021', 'LHP03', '2023-12-10', 'GV04', 90, N'Xuất sắc', 95, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV022', 'LHP03', '2023-12-10', 'GV04', 60, N'Trung bình', 65, 5, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV023', 'LHP03', '2023-12-10', 'GV04', 75, N'Khá', 70, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV024', 'LHP03', '2023-12-10', 'GV04', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV025', 'LHP04', '2024-05-10', 'GV03', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất tích cực'),
('SV026', 'LHP04', '2024-05-10', 'GV03', 80, N'Khá', 85, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV027', 'LHP04', '2024-05-10', 'GV03', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực tham gia'),
('SV028', 'LHP04', '2024-05-10', 'GV03', 60, N'Kém', 70, 5, N'Thụ động', N'Kém', N'Trung bình', N'Cần cải thiện'),
('SV029', 'LHP04', '2024-05-10', 'GV03', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt'),
('SV030', 'LHP04', '2024-05-10', 'GV03', 50, N'Trung bình', 60, 4, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV031', 'LHP04', '2024-05-10', 'GV03', 75, N'Khá', 70, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV032', 'LHP04', '2024-05-10', 'GV03', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV033', 'LHP05', '2024-05-10', 'GV07', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV034', 'LHP05', '2024-05-10', 'GV07', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV035', 'LHP05', '2024-05-10', 'GV07', 70, N'Trung bình', 75, 6, N'Thụ động', N'Trung bình', N'Trung bình', N'Vắng một số buổi'),
('SV036', 'LHP05', '2024-05-10', 'GV07', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV037', 'LHP05', '2024-05-10', 'GV07', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', NULL),
('SV038', 'LHP05', '2024-05-10', 'GV07', 60, N'Kém', 70, 5, N'Thụ động', N'Kém', N'Trung bình', N'Cần cải thiện'),
('SV039', 'LHP05', '2024-05-10', 'GV07', 75, N'Khá', 70, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV040', 'LHP05', '2024-05-10', 'GV07', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV041', 'LHP08', '2024-12-10', 'GV09', 90, N'Xuất sắc', 95, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV042', 'LHP08', '2024-12-10', 'GV09', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV043', 'LHP08', '2024-12-10', 'GV09', 40, N'Kém', 50, 3, N'Thụ động', N'Kém', N'Kém', N'Cần cải thiện'),
('SV044', 'LHP08', '2024-12-10', 'GV09', 75, N'Khá', 70, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV045', 'LHP08', '2024-12-10', 'GV09', 60, N'Trung bình', 65, 5, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV046', 'LHP08', '2024-12-10', 'GV09', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV047', 'LHP08', '2024-12-10', 'GV09', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV048', 'LHP08', '2024-12-10', 'GV09', 70, N'Khá', 75, 6, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV049', 'LHP09', '2024-12-10', 'GV11', 90, N'Xuất sắc', 95, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV050', 'LHP09', '2024-12-10', 'GV11', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV051', 'LHP09', '2024-12-10', 'GV11', 40, N'Kém', 50, 3, N'Thụ động', N'Kém', N'Kém', N'Cần cải thiện'),
('SV052', 'LHP09', '2024-12-10', 'GV11', 75, N'Khá', 70, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV053', 'LHP09', '2024-12-10', 'GV11', 60, N'Trung bình', 65, 5, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV054', 'LHP09', '2024-12-10', 'GV11', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV055', 'LHP09', '2024-12-10', 'GV11', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV056', 'LHP09', '2024-12-10', 'GV11', 70, N'Khá', 75, 6, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV057', 'LHP04', '2024-05-10', 'GV03', 70, N'Khá', 75, 6, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV058', 'LHP05', '2024-05-10', 'GV07', 80, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV059', 'LHP03', '2023-12-10', 'GV04', 60, N'Trung bình', 65, 5, N'Trung bình', N'Trung bình', N'Trung bình', N'Ổn định'),
('SV060', 'LHP05', '2024-05-10', 'GV07', 90, N'Xuất sắc', 95, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc');

-- Thêm dữ liệu vào bảng ViPhamKyLuat
INSERT INTO ViPhamKyLuat (maSinhVien, maLHP, ngayViPham, loaiViPham, mucDoViPham, bienPhapXuLy, diemTru, nguoiXuLy, trangThai, ghiChu) VALUES
('SV001', 'LHP01', '2023-11-20', N'Đi muộn nhiều lần', N'Nhẹ', N'Nhắc nhở', 5, 'GV01', N'Đã xử lý', N'Cam kết không tái phạm'),
('SV009', 'LHP02', '2023-11-20', N'Không nộp bài tập', N'Trung bình', N'Cảnh cáo', 10, 'GV02', N'Đã xử lý', N'Đã nộp bổ sung'),
('SV017', 'LHP03', '2023-11-20', N'Vi phạm nội quy lớp', N'Nghiêm trọng', N'Đình chỉ học 1 tuần', 20, 'GV04', N'Đã xử lý', N'Cam kết không tái phạm'),
('SV028', 'LHP04', '2024-03-05', N'Vắng mặt không phép', N'Trung bình', N'Cảnh cáo', 10, 'GV03', N'Đã xử lý', N'Vắng 2 buổi liên tiếp'),
('SV038', 'LHP05', '2024-03-15', N'Sử dụng điện thoại trong giờ', N'Nhẹ', N'Nhắc nhở', 5, 'GV07', N'Đã xử lý', N'Cam kết tuân thủ'),
('SV043', 'LHP08', '2024-09-18', N'Vắng mặt không phép', N'Trung bình', N'Cảnh cáo', 10, 'GV09', N'Đã xử lý', N'Vắng buổi học đầu tiên'),
('SV051', 'LHP09', '2024-09-19', N'Không nộp bài tập đúng hạn', N'Nhẹ', N'Nhắc nhở', 5, 'GV11', N'Đã xử lý', N'Cam kết nộp bổ sung'),
('SV057', 'LHP04', '2024-03-10', N'Sao chép bài tập', N'Nghiêm trọng', N'Đình chỉ học 2 tuần', 20, 'GV03', N'Đã xử lý', N'Cam kết không tái phạm'),
('SV059', 'LHP03', '2023-11-25', N'Sử dụng tài liệu trong kiểm tra', N'Rất nghiêm trọng', N'Đình chỉ học 1 tháng', 30, 'GV04', N'Đã xử lý', N'Cam kết tuân thủ quy định'),
('SV060', 'LHP05', '2024-03-20', N'Gây rối trong lớp', N'Trung bình', N'Cảnh cáo', 10, 'GV07', N'Đã xử lý', N'Cam kết không tái phạm');

-- Thêm dữ liệu vào bảng DiemRenLuyen
INSERT INTO DiemRenLuyen (maSinhVien, hocKy, namHoc, diemTuDanhGia, diemLop, diemKhoa, diemCuoiCung, xepLoai, nguoiDanhGia, ngayDanhGia, coHocBong, loaiHocBong, giaTriHocBong, ghiChu) VALUES
('SV001', '1', '2023-2024', 45, 40, 42, 35, N'Yếu', 'GV01', '2023-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV002', '1', '2023-2024', 60, 55, 58, 58, N'Trung bình', 'GV01', '2023-12-20', 0, NULL, NULL, NULL),
('SV003', '1', '2023-2024', 75, 70, 72, 72, N'Khá', 'GV01', '2023-12-20', 0, NULL, NULL, NULL),
('SV004', '1', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV01', '2023-12-20', 0, NULL, NULL, NULL),
('SV005', '1', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV01', '2023-12-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV006', '1', '2023-2024', 65, 60, 62, 62, N'Trung bình', 'GV01', '2023-12-20', 0, NULL, NULL, NULL),
('SV007', '1', '2023-2024', 80, 75, 78, 78, N'Khá', 'GV01', '2023-12-20', 0, NULL, NULL, NULL),
('SV008', '1', '2023-2024', 90, 85, 88, 88, N'Tốt', 'GV01', '2023-12-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV009', '1', '2023-2024', 50, 45, 48, 38, N'Yếu', 'GV02', '2023-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV010', '1', '2023-2024', 70, 65, 68, 68, N'Trung bình', 'GV02', '2023-12-20', 0, NULL, NULL, NULL),
('SV011', '1', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV02', '2023-12-20', 0, NULL, NULL, NULL),
('SV012', '1', '2023-2024', 90, 85, 88, 88, N'Tốt', 'GV02', '2023-12-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV013', '1', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV02', '2023-12-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV014', '1', '2023-2024', 60, 55, 58, 58, N'Trung bình', 'GV02', '2023-12-20', 0, NULL, NULL, NULL),
('SV015', '1', '2023-2024', 75, 70, 72, 72, N'Khá', 'GV02', '2023-12-20', 0, NULL, NULL, NULL),
('SV016', '1', '2023-2024', 80, 75, 78, 78, N'Khá', 'GV02', '2023-12-20', 0, NULL, NULL, NULL),
('SV017', '1', '2023-2024', 55, 50, 52, 32, N'Yếu', 'GV04', '2023-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV018', '1', '2023-2024', 70, 65, 68, 68, N'Trung bình', 'GV04', '2023-12-20', 0, NULL, NULL, NULL),
('SV019', '1', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV04', '2023-12-20', 0, NULL, NULL, NULL),
('SV020', '1', '2023-2024', 90, 85, 88, 88, N'Tốt', 'GV04', '2023-12-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV021', '1', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV04', '2023-12-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV022', '1', '2023-2024', 65, 60, 62, 62, N'Trung bình', 'GV04', '2023-12-20', 0, NULL, NULL, NULL),
('SV023', '1', '2023-2024', 80, 75, 78, 78, N'Khá', 'GV04', '2023-12-20', 0, NULL, NULL, NULL),
('SV024', '1', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV04', '2023-12-20', 0, NULL, NULL, NULL),
('SV025', '2', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV03', '2024-05-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV026', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV03', '2024-05-20', 0, NULL, NULL, NULL),
('SV027', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV03', '2024-05-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV028', '2', '2023-2024', 65, 60, 62, 52, N'Trung bình', 'GV03', '2024-05-20', 0, NULL, NULL, N'Có vi phạm'),
('SV029', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV03', '2024-05-20', 1, N'Khá', 5000000, N'Rất tốt'),
('SV030', '2', '2023-2024', 60, 55, 58, 58, N'Trung bình', 'GV03', '2024-05-20', 0, NULL, NULL, NULL),
('SV031', '2', '2023-2024', 75, 70, 72, 72, N'Khá', 'GV03', '2024-05-20', 0, NULL, NULL, NULL),
('SV032', '2', '2023-2024', 80, 75, 78, 78, N'Khá', 'GV03', '2024-05-20', 0, NULL, NULL, NULL),
('SV033', '2', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV07', '2024-05-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV034', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV07', '2024-05-20', 0, NULL, NULL, NULL),
('SV035', '2', '2023-2024', 75, 70, 72, 72, N'Khá', 'GV07', '2024-05-20', 0, NULL, NULL, NULL),
('SV036', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV07', '2024-05-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV037', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV07', '2024-05-20', 0, NULL, NULL, NULL),
('SV038', '2', '2023-2024', 65, 60, 62, 57, N'Trung bình', 'GV07', '2024-05-20', 0, NULL, NULL, N'Có vi phạm'),
('SV039', '2', '2023-2024', 80, 75, 78, 78, N'Khá', 'GV07', '2024-05-20', 0, NULL, NULL, NULL),
('SV040', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV07', '2024-05-20', 0, NULL, NULL, NULL),
('SV041', '1', '2024-2025', 95, 90, 92, 92, N'Xuất sắc', 'GV09', '2024-12-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV042', '1', '2024-2025', 85, 80, 82, 82, N'Khá', 'GV09', '2024-12-20', 0, NULL, NULL, NULL),
('SV043', '1', '2024-2025', 50, 45, 48, 38, N'Yếu', 'GV09', '2024-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV044', '1', '2024-2025', 75, 70, 72, 72, N'Khá', 'GV09', '2024-12-20', 0, NULL, NULL, NULL),
('SV045', '1', '2024-2025', 65, 60, 62, 62, N'Trung bình', 'GV09', '2024-12-20', 0, NULL, NULL, NULL),
('SV046', '1', '2024-2025', 85, 80, 82, 82, N'Khá', 'GV09', '2024-12-20', 0, NULL, NULL, NULL),
('SV047', '1', '2024-2025', 90, 85, 88, 88, N'Tốt', 'GV09', '2024-12-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV048', '1', '2024-2025', 70, 65, 68, 68, N'Trung bình', 'GV09', '2024-12-20', 0, NULL, NULL, NULL),
('SV049', '1', '2024-2025', 95, 90, 92, 92, N'Xuất sắc', 'GV11', '2024-12-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV050', '1', '2024-2025', 85, 80, 82, 82, N'Khá', 'GV11', '2024-12-20', 0, NULL, NULL, NULL),
('SV051', '1', '2024-2025', 50, 45, 48, 43, N'Yếu', 'GV11', '2024-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV052', '1', '2024-2025', 75, 70, 72, 72, N'Khá', 'GV11', '2024-12-20', 0, NULL, NULL, NULL),
('SV053', '1', '2024-2025', 65, 60, 62, 62, N'Trung bình', 'GV11', '2024-12-20', 0, NULL, NULL, NULL),
('SV054', '1', '2024-2025', 85, 80, 82, 82, N'Khá', 'GV11', '2024-12-20', 0, NULL, NULL, NULL),
('SV055', '1', '2024-2025', 90, 85, 88, 88, N'Tốt', 'GV11', '2024-12-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV056', '1', '2024-2025', 70, 65, 68, 68, N'Trung bình', 'GV11', '2024-12-20', 0, NULL, NULL, NULL),
('SV057', '2', '2023-2024', 75, 70, 72, 52, N'Trung bình', 'GV03', '2024-05-20', 0, NULL, NULL, N'Có vi phạm'),
('SV058', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV07', '2024-05-20', 0, NULL, NULL, NULL),
('SV059', '1', '2023-2024', 65, 60, 62, 32, N'Yếu', 'GV04', '2023-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV060', '2', '2023-2024', 95, 90, 92, 82, N'Khá', 'GV07', '2024-05-20', 0, NULL, NULL, N'Có vi phạm');

-- Thêm dữ liệu vào bảng ChiTietDanhGia
INSERT INTO ChiTietDanhGia (maDanhGia, maTieuChi, diem, ghiChu) VALUES
(1, 'TC01', 40, N'Tham gia kém'), (1, 'TC02', 50, N'Tập trung kém'), (1, 'TC03', 50, N'Hoàn thành bài tập kém'), (1, 'TC04', 3, N'Thảo luận kém'), (1, 'TC05', 40, N'Thụ động'), (1, 'TC06', 40, N'Làm việc nhóm kém'), (1, 'TC07', 40, N'Tôn trọng kém'), (1, 'TC08', 40, N'Kỷ luật kém'),
(2, 'TC01', 55, N'Tham gia trung bình'), (2, 'TC02', 60, N'Tập trung trung bình'), (2, 'TC03', 60, N'Hoàn thành bài tập trung bình'), (2, 'TC04', 4, N'Thảo luận trung bình'), (2, 'TC05', 70, N'Trung bình'), (2, 'TC06', 60, N'Làm việc nhóm trung bình'), (2, 'TC07', 60, N'Tôn trọng trung bình'), (2, 'TC08', 60, N'Kỷ luật trung bình'),
(3, 'TC01', 70, N'Tham gia khá'), (3, 'TC02', 75, N'Tập trung khá'), (3, 'TC03', 75, N'Hoàn thành bài tập khá'), (3, 'TC04', 6, N'Thảo luận khá'), (3, 'TC05', 70, N'Trung bình'), (3, 'TC06', 80, N'Làm việc nhóm khá'), (3, 'TC07', 80, N'Tôn trọng khá'), (3, 'TC08', 80, N'Kỷ luật khá'),
(4, 'TC01', 85, N'Tham gia tốt'), (4, 'TC02', 80, N'Tập trung tốt'), (4, 'TC03', 80, N'Hoàn thành bài tập tốt'), (4, 'TC04', 8, N'Thảo luận tốt'), (4, 'TC05', 100, N'Chủ động'), (4, 'TC06', 90, N'Làm việc nhóm tốt'), (4, 'TC07', 90, N'Tôn trọng tốt'), (4, 'TC08', 90, N'Kỷ luật tốt'),
(5, 'TC01', 95, N'Tham gia xuất sắc'), (5, 'TC02', 90, N'Tập trung xuất sắc'), (5, 'TC03', 90, N'Hoàn thành bài tập xuất sắc'), (5, 'TC04', 9, N'Thảo luận xuất sắc'), (5, 'TC05', 100, N'Rất chủ động'), (5, 'TC06', 95, N'Làm việc nhóm tốt'), (5, 'TC07', 95, N'Tôn trọng tốt'), (5, 'TC08', 95, N'Kỷ luật tốt'),
(41, 'TC01', 90, N'Tham gia xuất sắc'), (41, 'TC02', 95, N'Tập trung xuất sắc'), (41, 'TC03', 95, N'Hoàn thành bài tập xuất sắc'), (41, 'TC04', 9, N'Thảo luận xuất sắc'), (41, 'TC05', 100, N'Rất chủ động'), (41, 'TC06', 95, N'Làm việc nhóm tốt'), (41, 'TC07', 95, N'Tôn trọng tốt'), (41, 'TC08', 95, N'Kỷ luật tốt'),
(42, 'TC01', 80, N'Tham gia tốt'), (42, 'TC02', 85, N'Tập trung tốt'), (42, 'TC03', 85, N'Hoàn thành bài tập tốt'), (42, 'TC04', 8, N'Thảo luận tốt'), (42, 'TC05', 100, N'Chủ động'), (42, 'TC06', 90, N'Làm việc nhóm tốt'), (42, 'TC07', 90, N'Tôn trọng tốt'), (42, 'TC08', 90, N'Kỷ luật tốt'),
(43, 'TC01', 40, N'Tham gia kém'), (43, 'TC02', 50, N'Tập trung kém'), (43, 'TC03', 50, N'Hoàn thành bài tập kém'), (43, 'TC04', 3, N'Thảo luận kém'), (43, 'TC05', 40, N'Thụ động'), (43, 'TC06', 40, N'Làm việc nhóm kém'), (43, 'TC07', 40, N'Tôn trọng kém'), (43, 'TC08', 40, N'Kỷ luật kém'),
(44, 'TC01', 75, N'Tham gia khá'), (44, 'TC02', 70, N'Tập trung khá'), (44, 'TC03', 70, N'Hoàn thành bài tập khá'), (44, 'TC04', 7, N'Thảo luận khá'), (44, 'TC05', 70, N'Trung bình'), (44, 'TC06', 80, N'Làm việc nhóm khá'), (44, 'TC07', 80, N'Tôn trọng khá'), (44, 'TC08', 80, N'Kỷ luật khá'),
(45, 'TC01', 60, N'Tham gia trung bình'), (45, 'TC02', 65, N'Tập trung trung bình'), (45, 'TC03', 65, N'Hoàn thành bài tập trung bình'), (45, 'TC04', 5, N'Thảo luận trung bình'), (45, 'TC05', 70, N'Trung bình'), (45, 'TC06', 60, N'Làm việc nhóm trung bình'), (45, 'TC07', 60, N'Tôn trọng trung bình'), (45, 'TC08', 60, N'Kỷ luật trung bình');
-- 1. Liệt kê tất cả sinh viên trong hệ thống kèm thông tin lớp và ngành học
SELECT sv.maSinhVien, sv.hoTen, sv.gioiTinh, sv.email, 
       l.tenLop, n.tenNganh, k.tenKhoa
FROM SinhVien sv
JOIN Lop l ON sv.maLop = l.maLop
JOIN NganhHoc n ON sv.maNganh = n.maNganh
JOIN Khoa k ON sv.maKhoa = k.maKhoa
ORDER BY sv.maSinhVien;

-- 2 Hiển thị số lượng sinh viên theo từng ngành
SELECT n.maNganh, n.tenNganh, k.tenKhoa, 
       COUNT(sv.maSinhVien) AS SoLuongSinhVien
FROM NganhHoc n
LEFT JOIN SinhVien sv ON n.maNganh = sv.maNganh
JOIN Khoa k ON n.maKhoa = k.maKhoa
GROUP BY n.maNganh, n.tenNganh, k.tenKhoa
ORDER BY SoLuongSinhVien DESC;
-- 3 Tìm tất cả sinh viên đang học một môn học cụ thể

SELECT sv.maSinhVien, sv.hoTen, sv.email, l.tenLop
FROM SinhVien sv
JOIN DangKyHocPhan dkhp ON sv.maSinhVien = dkhp.maSinhVien
JOIN LopHocPhan lhp ON dkhp.maLHP = lhp.maLHP
JOIN MonHoc mh ON lhp.maMonHoc = mh.maMonHoc
JOIN Lop l ON sv.maLop = l.maLop
WHERE mh.tenMonHoc = N'Lập trình Java'
AND dkhp.trangThai = N'Hoàn thành'
ORDER BY sv.maSinhVien;

-- 4. Tìm tất giảng viên và môn học họ đang dạy trong học kỳ hiện tại
SELECT gv.maGiangVien, gv.hoTen AS TenGiangVien, 
       mh.maMonHoc, mh.tenMonHoc, 
       lhp.maLHP, lhp.hocKy, lhp.namHoc,
       lhp.soSinhVienHienTai
FROM GiangVien gv
JOIN LopHocPhan lhp ON gv.maGiangVien = lhp.maGiangVien
JOIN MonHoc mh ON lhp.maMonHoc = mh.maMonHoc
WHERE lhp.namHoc = '2023-2024' AND lhp.hocKy = '2'
ORDER BY gv.hoTen, mh.tenMonHoc;

-- 5. Liệt kê sinh viên có thái độ học tập xuất sắc
SELECT sv.maSinhVien, sv.hoTen, l.tenLop, n.tenNganh,
       dg.maLHP, mh.tenMonHoc, 
       dg.diemTongHop, dg.xepLoai
FROM SinhVien sv
JOIN DanhGiaThaiDoHocTap dg ON sv.maSinhVien = dg.maSinhVien
JOIN LopHocPhan lhp ON dg.maLHP = lhp.maLHP
JOIN MonHoc mh ON lhp.maMonHoc = mh.maMonHoc
JOIN Lop l ON sv.maLop = l.maLop
JOIN NganhHoc n ON sv.maNganh = n.maNganh
WHERE dg.xepLoai = N'Xuất sắc'
ORDER BY sv.maSinhVien, dg.diemTongHop DESC;

-- 6. Thống kê tỷ lệ vắng học theo từng lớp học phần
SELECT 
    lhp.maLHP, 
    mh.tenMonHoc, 
    gv.hoTen AS TenGiangVien,
    COUNT(DISTINCT dd.maSinhVien) AS SoSinhVienDiemDanh,
    COUNT(DISTINCT bh.maBuoi) AS SoBuoiHoc,
    SUM(CASE WHEN dd.trangThai = N'Vắng mặt' THEN 1 ELSE 0 END) AS SoLuotVangMat,
    CAST(SUM(CASE WHEN dd.trangThai = N'Vắng mặt' THEN 1 ELSE 0 END) * 100.0 / 
         NULLIF(COUNT(dd.maDiemDanh), 0) AS DECIMAL(5,2)) AS TyLeVangMat
FROM LopHocPhan lhp
JOIN MonHoc mh ON lhp.maMonHoc = mh.maMonHoc
JOIN GiangVien gv ON lhp.maGiangVien = gv.maGiangVien
LEFT JOIN BuoiHoc bh ON lhp.maLHP = bh.maLHP
LEFT JOIN DiemDanh dd ON bh.maBuoi = dd.maBuoi
WHERE bh.trangThai = N'Đã diễn ra'
GROUP BY lhp.maLHP, mh.tenMonHoc, gv.hoTen
ORDER BY TyLeVangMat DESC;

-- 7. Thống kê mức độ hoàn thành bài tập theo từng lớp học phần
SELECT 
    lhp.maLHP, 
    mh.tenMonHoc, 
    gv.hoTen AS TenGiangVien,
    COUNT(DISTINCT dg.maSinhVien) AS SoSinhVienDuocDanhGia,
    CAST(AVG(dg.hoanThanhBaiTap) AS DECIMAL(5,2)) AS TyLeHoanThanhTrungBinh,
    MIN(dg.hoanThanhBaiTap) AS TyLeThapNhat,
    MAX(dg.hoanThanhBaiTap) AS TyleCaoNhat,
    COUNT(CASE WHEN dg.hoanThanhBaiTap >= 90 THEN 1 END) AS SL_HoanThanhXuatSac,
    COUNT(CASE WHEN dg.hoanThanhBaiTap >= 80 AND dg.hoanThanhBaiTap < 90 THEN 1 END) AS SL_HoanThanhTot,
    COUNT(CASE WHEN dg.hoanThanhBaiTap >= 70 AND dg.hoanThanhBaiTap < 80 THEN 1 END) AS SL_HoanThanhKha,
    COUNT(CASE WHEN dg.hoanThanhBaiTap >= 50 AND dg.hoanThanhBaiTap < 70 THEN 1 END) AS SL_HoanThanhTrungBinh,
    COUNT(CASE WHEN dg.hoanThanhBaiTap < 50 THEN 1 END) AS SL_HoanThanhKem
FROM LopHocPhan lhp
JOIN MonHoc mh ON lhp.maMonHoc = mh.maMonHoc
JOIN GiangVien gv ON lhp.maGiangVien = gv.maGiangVien
JOIN DanhGiaThaiDoHocTap dg ON lhp.maLHP = dg.maLHP
GROUP BY lhp.maLHP, mh.tenMonHoc, gv.hoTen
ORDER BY TyLeHoanThanhTrungBinh DESC;

-- 8. Phân tích mối tương quan giữa tỷ lệ tham gia học tập và điểm tổng hợp
WITH NhomThamGia AS (
    SELECT 
        CASE 
            WHEN tyLeThamGia >= 90 THEN N'90-100%'
            WHEN tyLeThamGia >= 80 THEN N'80-89%'
            WHEN tyLeThamGia >= 70 THEN N'70-79%'
            WHEN tyLeThamGia >= 60 THEN N'60-69%'
            WHEN tyLeThamGia >= 50 THEN N'50-59%'
            ELSE N'Dưới 50%'
        END AS NhomTyLeThamGia,
        maSinhVien,
        diemTongHop
    FROM DanhGiaThaiDoHocTap
)
SELECT 
    NhomTyLeThamGia,
    COUNT(*) AS SoLuongSinhVien,
    CAST(AVG(diemTongHop) AS DECIMAL(5,2)) AS DiemTongHopTrungBinh,
    CAST(MIN(diemTongHop) AS DECIMAL(5,2)) AS DiemTongHopThapNhat,
    CAST(MAX(diemTongHop) AS DECIMAL(5,2)) AS DiemTongHopCaoNhat,
    CAST(STDEV(diemTongHop) AS DECIMAL(5,2)) AS DoLechChuan,
    COUNT(CASE WHEN diemTongHop >= 90 THEN 1 END) AS SL_XuatSac,
    COUNT(CASE WHEN diemTongHop >= 80 AND diemTongHop < 90 THEN 1 END) AS SL_Tot,
    COUNT(CASE WHEN diemTongHop >= 65 AND diemTongHop < 80 THEN 1 END) AS SL_Kha,
    COUNT(CASE WHEN diemTongHop >= 50 AND diemTongHop < 65 THEN 1 END) AS SL_TrungBinh,
    COUNT(CASE WHEN diemTongHop < 50 THEN 1 END) AS SL_Yeu
FROM NhomThamGia
GROUP BY NhomTyLeThamGia
ORDER BY 
    CASE 
        WHEN NhomTyLeThamGia = N'90-100%' THEN 1
        WHEN NhomTyLeThamGia = N'80-89%' THEN 2
        WHEN NhomTyLeThamGia = N'70-79%' THEN 3
        WHEN NhomTyLeThamGia = N'60-69%' THEN 4
        WHEN NhomTyLeThamGia = N'50-59%' THEN 5
        ELSE 6
    END;

-- 9. Thống kê học bổng xuất sắc dựa trên điểm rèn luyện và điểm học phần
WITH DiemTrungBinhSinhVien AS (
    SELECT 
        sv.maSinhVien,
        AVG(CASE WHEN dkhp.diemTong IS NOT NULL THEN dkhp.diemTong ELSE NULL END) AS DiemTrungBinhHocTap
    FROM SinhVien sv
    LEFT JOIN DangKyHocPhan dkhp ON sv.maSinhVien = dkhp.maSinhVien
    WHERE dkhp.diemTong IS NOT NULL
    GROUP BY sv.maSinhVien
)
SELECT 
    sv.maSinhVien, 
    sv.hoTen, 
    l.tenLop,
    n.tenNganh,
    drl.hocKy,
    drl.namHoc,
    tb.DiemTrungBinhHocTap,
    drl.diemCuoiCung AS DiemRenLuyen,
    drl.xepLoai AS XepLoaiRenLuyen,
    drl.coHocBong,
    drl.loaiHocBong,
    drl.giaTriHocBong,
    CASE 
        WHEN tb.DiemTrungBinhHocTap >= 3.6 AND drl.diemCuoiCung >= 90 THEN N'Học bổng Xuất sắc'
        ELSE N'Không đủ điều kiện'
    END AS DeXuatHocBong,
    CASE 
        WHEN tb.DiemTrungBinhHocTap >= 3.6 AND drl.diemCuoiCung >= 90 THEN 10000000
        ELSE 0
    END AS GiaTriDeXuat
FROM SinhVien sv
JOIN Lop l ON sv.maLop = l.maLop
JOIN NganhHoc n ON sv.maNganh = n.maNganh
JOIN DiemRenLuyen drl ON sv.maSinhVien = drl.maSinhVien
LEFT JOIN DiemTrungBinhSinhVien tb ON sv.maSinhVien = tb.maSinhVien
WHERE drl.hocKy = '1' AND drl.namHoc = '2023-2024'
ORDER BY 
    CASE 
        WHEN tb.DiemTrungBinhHocTap >= 3.6 AND drl.diemCuoiCung >= 90 THEN 1
        ELSE 2
    END,
    tb.DiemTrungBinhHocTap DESC, drl.diemCuoiCung DESC;
--10. Liệt kê sinh viên có nguy cơ học tập yếu dựa trên điểm học phần và điểm rèn luyện
WITH DiemHocPhanTrungBinh AS (
    SELECT 
        dkhp.maSinhVien, 
        lhp.hocKy, 
        lhp.namHoc, 
        AVG(CASE WHEN dkhp.diemTong IS NOT NULL THEN dkhp.diemTong END) AS DiemHocPhanTrungBinh
    FROM DangKyHocPhan dkhp
    JOIN LopHocPhan lhp ON dkhp.maLHP = lhp.maLHP
    WHERE dkhp.trangThai = N'Hoàn thành'
    GROUP BY dkhp.maSinhVien, lhp.hocKy, lhp.namHoc
)
SELECT 
    sv.maSinhVien, 
    sv.hoTen, 
    l.tenLop, 
    n.tenNganh, 
    dhptb.hocKy, 
    dhptb.namHoc, 
    CAST(dhptb.DiemHocPhanTrungBinh AS DECIMAL(4,2)) AS DiemHocPhanTrungBinh,
    drl.diemCuoiCung AS DiemRenLuyen,
    drl.xepLoai AS XepLoaiRenLuyen,
    CASE 
        WHEN dhptb.DiemHocPhanTrungBinh < 6.0 AND drl.diemCuoiCung < 50 THEN N'Rủi ro cao'
        WHEN dhptb.DiemHocPhanTrungBinh < 6.0 OR drl.diemCuoiCung < 50 THEN N'Rủi ro trung bình'
        ELSE N'Bình thường'
    END AS MucDoRuiRo,
    CASE 
        WHEN dhptb.DiemHocPhanTrungBinh < 6.0 THEN N'Điểm học phần thấp'
        WHEN drl.diemCuoiCung < 50 THEN N'Điểm rèn luyện thấp'
        ELSE NULL
    END AS LyDoRuiRo
FROM SinhVien sv
JOIN Lop l ON sv.maLop = l.maLop
JOIN NganhHoc n ON sv.maNganh = n.maNganh
LEFT JOIN DiemHocPhanTrungBinh dhptb ON sv.maSinhVien = dhptb.maSinhVien
LEFT JOIN DiemRenLuyen drl ON sv.maSinhVien = drl.maSinhVien 
    AND drl.hocKy = dhptb.hocKy 
    AND drl.namHoc = dhptb.namHoc
WHERE (dhptb.DiemHocPhanTrungBinh < 6.0 OR drl.diemCuoiCung < 50)
    AND dhptb.hocKy = '1' 
    AND dhptb.namHoc = '2023-2024'
ORDER BY MucDoRuiRo DESC, dhptb.DiemHocPhanTrungBinh ASC, drl.diemCuoiCung ASC;
--11. Phân tích tác động của vi phạm kỷ luật đến học bổng của sinh viên
SELECT 
    sv.maSinhVien, 
    sv.hoTen, 
    l.tenLop, 
    n.tenNganh, 
    drl.hocKy, 
    drl.namHoc, 
    COUNT(vp.maViPham) AS SoLuongViPham,
    SUM(vp.diemTru) AS TongDiemTru,
    drl.diemCuoiCung AS DiemRenLuyen,
    drl.xepLoai AS XepLoaiRenLuyen,
    drl.coHocBong,
    drl.loaiHocBong,
    drl.giaTriHocBong,
    CASE 
        WHEN drl.diemCuoiCung >= 90 AND SUM(vp.diemTru) = 0 THEN N'Đủ điều kiện học bổng Xuất sắc'
        WHEN drl.diemCuoiCung >= 80 AND SUM(vp.diemTru) = 0 THEN N'Đủ điều kiện học bổng Khá'
        WHEN SUM(vp.diemTru) > 0 THEN N'Không đủ điều kiện do vi phạm'
        ELSE N'Không đủ điều kiện điểm rèn luyện'
    END AS TrangThaiHocBong,
    STRING_AGG(CASE WHEN vp.maViPham IS NOT NULL THEN vp.loaiViPham + ' (' + vp.mucDoViPham + ')' END, '; ') AS ChiTietViPham
FROM SinhVien sv
JOIN Lop l ON sv.maLop = l.maLop
JOIN NganhHoc n ON sv.maNganh = n.maNganh
JOIN DiemRenLuyen drl ON sv.maSinhVien = drl.maSinhVien
LEFT JOIN ViPhamKyLuat vp ON sv.maSinhVien = vp.maSinhVien 
    AND drl.hocKy = (SELECT lhp.hocKy FROM LopHocPhan lhp WHERE lhp.maLHP = vp.maLHP)
    AND drl.namHoc = (SELECT lhp.namHoc FROM LopHocPhan lhp WHERE lhp.maLHP = vp.maLHP)
WHERE drl.hocKy = '1' AND drl.namHoc = '2023-2024'
GROUP BY sv.maSinhVien, sv.hoTen, l.tenLop, n.tenNganh, drl.hocKy, drl.namHoc, 
         drl.diemCuoiCung, drl.xepLoai, drl.coHocBong, drl.loaiHocBong, drl.giaTriHocBong
HAVING COUNT(vp.maViPham) > 0 OR drl.diemCuoiCung < 90
ORDER BY TongDiemTru DESC, drl.diemCuoiCung ASC;


