
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
GO
drop database QuanLyThaiDoHocTap;
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

CREATE TABLE Khoa (
    maKhoa VARCHAR(10) PRIMARY KEY,
    tenKhoa NVARCHAR(100) NOT NULL,
    truongKhoa NVARCHAR(100),
    moTa NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE()
);
GO

-- Bảng Ngành học
CREATE TABLE NganhHoc (
    maNganh VARCHAR(10) PRIMARY KEY,
    tenNganh NVARCHAR(100) NOT NULL,
    maKhoa VARCHAR(10) NOT NULL,
    moTa NVARCHAR(MAX),
    ngayTao DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (maKhoa) REFERENCES Khoa(maKhoa)
);
GO

-- Bảng Giảng viên
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

-- Bảng Lớp học
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

-- Bảng Sinh viên
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

-- Bảng Môn học
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

-- Bảng Tiêu chí đánh giá thái độ học tập
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

-- Bảng Lớp học phần
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

-- Bảng Đăng ký học phần
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

-- Bảng Buổi học
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

-- Bảng Điểm danh
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

-- Bảng Đánh giá thái độ học tập
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

-- Bảng Vi phạm kỷ luật
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

-- Bảng Điểm rèn luyện tổng hợp học kỳ
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

-- Bảng Chi tiết đánh giá theo tiêu chí
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

-- Trigger cập nhật tỷ lệ tham gia từ điểm danh (Corrected)
CREATE TRIGGER trg_CapNhat_TyLeThamGia
ON DiemDanh
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @SinhVienLHPToUpdate TABLE (
        maSinhVien VARCHAR(10),
        maLHP VARCHAR(20)
    );
    
    -- Insert from inserted records
    INSERT INTO @SinhVienLHPToUpdate
    SELECT DISTINCT i.maSinhVien, bh.maLHP
    FROM inserted i
    JOIN BuoiHoc bh ON i.maBuoi = bh.maBuoi;
    
    -- Insert from deleted records
    INSERT INTO @SinhVienLHPToUpdate
    SELECT DISTINCT d.maSinhVien, bh.maLHP
    FROM deleted d
    JOIN BuoiHoc bh ON d.maBuoi = bh.maBuoi;
    
    -- Update DanhGiaThaiDoHocTap with explicit table references
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


-- Thêm dữ liệu vào bảng Khoa (Đại diện các khoa tại UTC2)
INSERT INTO Khoa (maKhoa, tenKhoa, truongKhoa, moTa) VALUES
('K01', N'Công trình', N'Nguyễn Văn Hùng', N'Khoa chuyên về kỹ thuật xây dựng và giao thông'),
('K02', N'Vận tải - Kinh tế', N'Trần Thị B', N'Khoa đào tạo kinh tế và quản lý vận tải'),
('K03', N'Cơ khí - Công nghệ', N'Lê Văn C', N'Khoa chuyên về cơ khí và công nghệ'),
('K04', N'Công nghệ Thông tin', N'Phạm Thị D', N'Khoa đào tạo công nghệ thông tin'),
('K05', N'Khoa học Cơ bản', N'Hoàng Văn E', N'Khoa đào tạo các môn cơ bản');

-- Thêm dữ liệu vào bảng NganhHoc (Dựa trên các ngành của UTC2)
INSERT INTO NganhHoc (maNganh, tenNganh, maKhoa, moTa) VALUES
('N01', N'Kỹ thuật xây dựng công trình giao thông', 'K01', N'Ngành đào tạo kỹ sư xây dựng giao thông'),
('N02', N'Quản trị kinh doanh', 'K02', N'Ngành đào tạo quản trị doanh nghiệp'),
('N03', N'Công nghệ thông tin', 'K04', N'Ngành đào tạo chuyên gia công nghệ thông tin'),
('N04', N'Kỹ thuật ô tô', 'K03', N'Ngành đào tạo kỹ sư ô tô'),
('N05', N'Logistics và Quản lý chuỗi cung ứng', 'K02', N'Ngành đào tạo logistics'),
('N06', N'Kỹ thuật điện tử - viễn thông', 'K03', N'Ngành đào tạo kỹ sư điện tử'),
('N07', N'Kế toán', 'K02', N'Ngành đào tạo kế toán tài chính'),
('N08', N'Kinh tế xây dựng', 'K01', N'Ngành đào tạo kinh tế trong xây dựng'),
('N09', N'Kỹ thuật cơ điện tử', 'K03', N'Ngành đào tạo kỹ sư cơ điện tử'),
('N10', N'Khai thác vận tải', 'K02', N'Ngành đào tạo quản lý vận tải');

-- Thêm dữ liệu vào bảng GiangVien (Thêm 20 giảng viên)
INSERT INTO GiangVien (maGiangVien, hoTen, gioiTinh, email, soDienThoai, maKhoa, chucVu) VALUES
('GV01', N'Nguyễn Văn Hùng', N'Nam', 'hungnv@utc2.edu.vn', '0912345678', 'K01', N'Phó Giám đốc Phân hiệu'),
('GV02', N'Trần Thị Mai', N'Nữ', 'mai.tt@utc2.edu.vn', '0987654321', 'K02', N'Phó khoa'),
('GV03', N'Lê Văn Tuấn', N'Nam', 'tuanlv@utc2.edu.vn', '0901234567', 'K03', N'Giảng viên'),
('GV04', N'Phạm Thị Lan', N'Nữ', 'lanpt@utc2.edu.vn', '0978123456', 'K04', N'Giảng viên chính'),
('GV05', N'Hoàng Văn Nam', N'Nam', 'namhv@utc2.edu.vn', '0932123456', 'K05', N'Trưởng khoa'),
('GV06', N'Đỗ Thị Hà', N'Nữ', 'hado@utc2.edu.vn', '0918765432', 'K01', N'Giảng viên'),
('GV07', N'Vũ Văn Long', N'Nam', 'longvv@utc2.edu.vn', '0981234567', 'K02', N'Giảng viên'),
('GV08', N'Nguyễn Thị Hoa', N'Nữ', 'hoant@utc2.edu.vn', '0967891234', 'K03', N'Phó khoa'),
('GV09', N'Trần Văn Khánh', N'Nam', 'khanhtv@utc2.edu.vn', '0945678901', 'K04', N'Giảng viên'),
('GV10', N'Lê Thị Minh', N'Nữ', 'minhlt@utc2.edu.vn', '0923456789', 'K05', N'Giảng viên'),
('GV11', N'Phạm Văn Bình', N'Nam', 'binhpv@utc2.edu.vn', '0919876543', 'K01', N'Giảng viên chính'),
('GV12', N'Nguyễn Thị Ngọc', N'Nữ', 'ngocnt@utc2.edu.vn', '0984561237', 'K02', N'Giảng viên'),
('GV13', N'Trần Văn Đức', N'Nam', 'ductv@utc2.edu.vn', '0936789012', 'K03', N'Giảng viên'),
('GV14', N'Lê Thị Thu', N'Nữ', 'thult@utc2.edu.vn', '0971234568', 'K04', N'Phó khoa'),
('GV15', N'Hoàng Văn Anh', N'Nam', 'anhhv@utc2.edu.vn', '0947891234', 'K05', N'Giảng viên'),
('GV16', N'Đỗ Văn Hùng', N'Nam', 'hungdv@utc2.edu.vn', '0913456789', 'K01', N'Giảng viên'),
('GV17', N'Vũ Thị Lan', N'Nữ', 'lanvt@utc2.edu.vn', '0989012345', 'K02', N'Giảng viên'),
('GV18', N'Nguyễn Văn Tâm', N'Nam', 'tamnv@utc2.edu.vn', '0961237890', 'K03', N'Giảng viên chính'),
('GV19', N'Trần Thị Hồng', N'Nữ', 'hongtt@utc2.edu.vn', '0926789012', 'K04', N'Giảng viên'),
('GV20', N'Lê Văn Sơn', N'Nam', 'sonlv@utc2.edu.vn', '0951234567', 'K05', N'Giảng viên');

-- Thêm dữ liệu vào bảng Lop (Thêm 10 lớp)
INSERT INTO Lop (maLop, tenLop, maKhoa, maNganh, maGVCN, namBatDau) VALUES
('L01', N'KXDG01', 'K01', 'N01', 'GV01', 2023),
('L02', N'QTKD01', 'K02', 'N02', 'GV02', 2023),
('L03', N'CNTT01', 'K04', 'N03', 'GV04', 2023),
('L04', N'KTO01', 'K03', 'N04', 'GV03', 2023),
('L05', N'LOG01', 'K02', 'N05', 'GV07', 2023),
('L06', N'KTDDT01', 'K03', 'N06', 'GV08', 2024),
('L07', N'KT01', 'K02', 'N07', 'GV12', 2024),
('L08', N'KTXD01', 'K01', 'N08', 'GV11', 2024),
('L09', N'KCDT01', 'K03', 'N09', 'GV13', 2024),
('L10', N'KHVT01', 'K02', 'N10', 'GV17', 2024);

-- Thêm dữ liệu vào bảng SinhVien (Thêm 50 sinh viên, phân bổ đều cho các lớp)
INSERT INTO SinhVien (maSinhVien, hoTen, ngaySinh, gioiTinh, email, soDienThoai, diaChi, CCCD, maLop, maNganh, maKhoa, namNhapHoc, trangThai) VALUES
('SV001', N'Nguyễn Văn Nam', '2003-05-10', N'Nam', 'namnv001@utc2.edu.vn', '0912345679', N'TP.HCM', '123456789001', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV002', N'Lê Thị Hồng', '2003-07-15', N'Nữ', 'honglt002@utc2.edu.vn', '0987654322', N'Bình Dương', '987654321002', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV003', N'Trần Văn Hùng', '2002-03-22', N'Nam', 'hungtv003@utc2.edu.vn', '0901234568', N'Đồng Nai', '123456789003', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV004', N'Phạm Thị Mai', '2003-11-30', N'Nữ', 'maipt004@utc2.edu.vn', '0978123457', N'TP.HCM', '987654321004', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV005', N'Hoàng Văn Tâm', '2002-09-05', N'Nam', 'tamhv005@utc2.edu.vn', '0932123457', N'Long An', '123456789005', 'L01', 'N01', 'K01', 2023, N'Đang học'),
('SV006', N'Nguyễn Thị Lan', '2003-01-12', N'Nữ', 'lannt006@utc2.edu.vn', '0918765433', N'TP.HCM', '987654321006', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV007', N'Vũ Văn Long', '2002-06-18', N'Nam', 'longvv007@utc2.edu.vn', '0981234568', N'Bình Phước', '123456789007', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV008', N'Trần Thị Hoa', '2003-04-25', N'Nữ', 'hoatt008@utc2.edu.vn', '0967891235', N'TP.HCM', '987654321008', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV009', N'Lê Văn Khánh', '2002-08-14', N'Nam', 'khanhlv009@utc2.edu.vn', '0945678902', N'Đồng Nai', '123456789009', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV010', N'Phạm Thị Minh', '2003-02-28', N'Nữ', 'minhpt010@utc2.edu.vn', '0923456790', N'TP.HCM', '987654321010', 'L02', 'N02', 'K02', 2023, N'Đang học'),
('SV011', N'Nguyễn Văn Bình', '2003-10-03', N'Nam', 'binhnv011@utc2.edu.vn', '0919876544', 'Tiền Giang', '123456789011', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV012', N'Trần Thị Ngọc', '2002-12-19', N'Nữ', 'ngoctt012@utc2.edu.vn', '0984561238', N'TP.HCM', '987654321012', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV013', N'Lê Văn Đức', '2003-05-07', N'Nam', 'duclv013@utc2.edu.vn', '0936789013', 'Bình Dương', '123456789013', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV014', N'Phạm Thị Thu', '2002-07-23', N'Nữ', 'thupt014@utc2.edu.vn', '0971234569', 'TP.HCM', '987654321014', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV015', N'Hoàng Văn Anh', '2003-03-15', N'Nam', 'anhhv015@utc2.edu.vn', '0947891235', 'Đồng Nai', '123456789015', 'L03', 'N03', 'K04', 2023, N'Đang học'),
('SV016', N'Nguyễn Văn Hùng', '2004-01-10', N'Nam', 'hungnv016@utc2.edu.vn', '0913456790', 'TP.HCM', '123456789016', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV017', N'Trần Thị Lan', '2004-06-22', N'Nữ', 'lantt017@utc2.edu.vn', '0989012346', 'Long An', '987654321017', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV018', N'Lê Văn Tâm', '2004-09-08', N'Nam', 'tamhv018@utc2.edu.vn', '0961237891', 'TP.HCM', '123456789018', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV019', N'Phạm Thị Hồng', '2004-02-14', N'Nữ', 'hongpt019@utc2.edu.vn', '0926789013', 'Bình Dương', '987654321019', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV020', N'Hoàng Văn Sơn', '2004-11-27', N'Nam', 'sonhv020@utc2.edu.vn', '0951234568', 'TP.HCM', '123456789020', 'L04', 'N04', 'K03', 2024, N'Đang học'),
('SV021', N'Nguyễn Thị Mai', '2003-08-16', N'Nữ', 'maint021@utc2.edu.vn', '0912345680', 'Đồng Nai', '987654321021', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV022', N'Trần Văn Long', '2003-04-29', N'Nam', 'longtv022@utc2.edu.vn', '0987654323', 'TP.HCM', '123456789022', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV023', N'Lê Thị Hoa', '2003-12-05', N'Nữ', 'hoalt023@utc2.edu.vn', '0901234569', 'Bình Phước', '987654321023', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV024', N'Phạm Văn Khánh', '2003-06-11', N'Nam', 'khanhpv024@utc2.edu.vn', '0978123458', 'TP.HCM', '123456789024', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV025', N'Hoàng Thị Minh', '2003-02-17', N'Nữ', 'minhht025@utc2.edu.vn', '0932123458', 'Long An', '987654321025', 'L05', 'N05', 'K02', 2023, N'Đang học'),
('SV026', N'Nguyễn Văn Đức', '2004-03-20', N'Nam', 'ducnv026@utc2.edu.vn', '0918765434', 'TP.HCM', '123456789026', 'L06', 'N06', 'K03', 2024, N'Đang học'),
('SV027', N'Trần Thị Thu', '2004-07-09', N'Nữ', 'thutt027@utc2.edu.vn', '0981234569', 'Bình Dương', '987654321027', 'L06', 'N06', 'K03', 2024, N'Đang học'),
('SV028', N'Lê Văn Anh', '2004-10-25', N'Nam', 'anhlv028@utc2.edu.vn', '0967891236', 'TP.HCM', '123456789028', 'L06', 'N06', 'K03', 2024, N'Đang học'),
('SV029', N'Phạm Thị Lan', '2004-05-13', N'Nữ', 'lanpt029@utc2.edu.vn', '0945678903', 'Đồng Nai', '987654321029', 'L06', 'N06', 'K03', 2024, N'Đang học'),
('SV030', N'Hoàng Văn Tâm', '2004-01-30', N'Nam', 'tamhv030@utc2.edu.vn', '0923456791', 'TP.HCM', '123456789030', 'L06', 'N06', 'K03', 2024, N'Đang học'),
('SV031', N'Nguyễn Thị Hồng', '2003-09-04', N'Nữ', 'hongnt031@utc2.edu.vn', '0919876545', 'Tiền Giang', '987654321031', 'L07', 'N07', 'K02', 2023, N'Đang học'),
('SV032', N'Trần Văn Sơn', '2003-11-20', N'Nam', 'sontv032@utc2.edu.vn', '0984561239', 'TP.HCM', '123456789032', 'L07', 'N07', 'K02', 2023, N'Đang học'),
('SV033', N'Lê Thị Mai', '2003-06-26', N'Nữ', 'mailt033@utc2.edu.vn', '0936789014', 'Bình Dương', '987654321033', 'L07', 'N07', 'K02', 2023, N'Đang học'),
('SV034', N'Phạm Văn Long', '2003-02-02', N'Nam', 'longpv034@utc2.edu.vn', '0971234570', 'TP.HCM', '123456789034', 'L07', 'N07', 'K02', 2023, N'Đang học'),
('SV035', N'Hoàng Thị Hoa', '2003-10-08', N'Nữ', 'hoant035@utc2.edu.vn', '0947891236', 'Đồng Nai', '987654321035', 'L07', 'N07', 'K02', 2023, N'Đang học'),
('SV036', N'Nguyễn Văn Khánh', '2004-04-15', N'Nam', 'khanhnv036@utc2.edu.vn', '0913456791', 'TP.HCM', '123456789036', 'L08', 'N08', 'K01', 2024, N'Đang học'),
('SV037', N'Trần Thị Minh', '2004-08-01', N'Nữ', 'minhtt037@utc2.edu.vn', '0989012347', 'Long An', '987654321037', 'L08', 'N08', 'K01', 2024, N'Đang học'),
('SV038', N'Lê Văn Đức', '2004-12-17', N'Nam', 'duclv038@utc2.edu.vn', '0961237892', 'TP.HCM', '123456789038', 'L08', 'N08', 'K01', 2024, N'Đang học'),
('SV039', N'Phạm Thị Thu', '2004-07-24', N'Nữ', 'thupt039@utc2.edu.vn', '0926789014', 'Bình Dương', '987654321039', 'L08', 'N08', 'K01', 2024, N'Đang học'),
('SV040', N'Hoàng Văn Anh', '2004-03-10', N'Nam', 'anhhv040@utc2.edu.vn', '0951234569', 'TP.HCM', '123456789040', 'L08', 'N08', 'K01', 2024, N'Đang học'),
('SV041', N'Nguyễn Thị Lan', '2003-05-16', N'Nữ', 'lannt041@utc2.edu.vn', '0912345681', 'Đồng Nai', '987654321041', 'L09', 'N09', 'K03', 2023, N'Đang học'),
('SV042', N'Trần Văn Tâm', '2003-09-22', N'Nam', 'tamtv042@utc2.edu.vn', '0987654324', 'TP.HCM', '123456789042', 'L09', 'N09', 'K03', 2023, N'Đang học'),
('SV043', N'Lê Thị Hồng', '2003-01-28', N'Nữ', 'honglt043@utc2.edu.vn', '0901234570', 'Bình Phước', '987654321043', 'L09', 'N09', 'K03', 2023, N'Đang học'),
('SV044', N'Phạm Văn Sơn', '2003-07-05', N'Nam', 'sonpv044@utc2.edu.vn', '0978123459', 'TP.HCM', '123456789044', 'L09', 'N09', 'K03', 2023, N'Đang học'),
('SV045', N'Hoàng Thị Mai', '2003-11-11', N'Nữ', 'maint045@utc2.edu.vn', '0932123459', 'Long An', '987654321045', 'L09', 'N09', 'K03', 2023, N'Đang học'),
('SV046', N'Nguyễn Văn Long', '2004-02-18', N'Nam', 'longnv046@utc2.edu.vn', '0918765435', 'TP.HCM', '123456789046', 'L10', 'N10', 'K02', 2024, N'Đang học'),
('SV047', N'Trần Thị Hoa', '2004-06-24', N'Nữ', 'hoatt047@utc2.edu.vn', '0981234570', 'Bình Dương', '987654321047', 'L10', 'N10', 'K02', 2024, N'Đang học'),
('SV048', N'Lê Văn Khánh', '2004-10-30', N'Nam', 'khanhlv048@utc2.edu.vn', '0967891237', 'TP.HCM', '123456789048', 'L10', 'N10', 'K02', 2024, N'Đang học'),
('SV049', N'Phạm Thị Minh', '2004-04-06', N'Nữ', 'minhpt049@utc2.edu.vn', '0945678904', 'Đồng Nai', '987654321049', 'L10', 'N10', 'K02', 2024, N'Đang học'),
('SV050', N'Hoàng Văn Đức', '2004-08-12', N'Nam', 'duchv050@utc2.edu.vn', '0923456792', 'TP.HCM', '123456789050', 'L10', 'N10', 'K02', 2024, N'Đang học');

-- Thêm dữ liệu vào bảng MonHoc (Thêm 15 môn học)
INSERT INTO MonHoc (maMonHoc, tenMonHoc, soTinChi, maKhoa, moTa) VALUES
('MH01', N'Kỹ thuật xây dựng', 3, 'K01', N'Môn học về kỹ thuật xây dựng công trình giao thông'),
('MH02', N'Quản trị marketing', 3, 'K02', N'Môn học về chiến lược marketing'),
('MH03', N'Lập trình Java', 3, 'K04', N'Môn học về lập trình Java cơ bản'),
('MH04', N'Công nghệ ô tô', 3, 'K03', N'Môn học về công nghệ và bảo trì ô tô'),
('MH05', N'Quản lý chuỗi cung ứng', 3, 'K02', N'Môn học về logistics và chuỗi cung ứng'),
('MH06', N'Điện tử viễn thông', 3, 'K03', N'Môn học về hệ thống viễn thông'),
('MH07', N'Kế toán tài chính', 3, 'K02', N'Môn học về kế toán doanh nghiệp'),
('MH08', N'Kinh tế xây dựng', 3, 'K01', N'Môn học về quản lý chi phí xây dựng'),
('MH09', N'Cơ điện tử', 3, 'K03', N'Môn học về hệ thống cơ điện tử'),
('MH10', N'Quản lý vận tải', 3, 'K02', N'Môn học về quản lý vận tải'),
('MH11', N'Toán cao cấp', 3, 'K05', N'Môn học cơ bản về toán học'),
('MH12', N'Vật lý kỹ thuật', 3, 'K05', N'Môn học cơ bản về vật lý'),
('MH13', N'Tin học cơ bản', 3, 'K04', N'Môn học về kỹ năng tin học'),
('MH14', N'Sức bền vật liệu', 3, 'K01', N'Môn học về cơ học vật liệu'),
('MH15', N'Triết học', 2, 'K05', N'Môn học về triết học cơ bản');

-- Thêm dữ liệu vào bảng TieuChiDanhGia (Thêm 8 tiêu chí)
INSERT INTO TieuChiDanhGia (maTieuChi, tenTieuChi, loaiTieuChi, moTa, diemToiDa, trongSo) VALUES
('TC01', N'Tỷ lệ tham gia', N'Tham gia', N'Đánh giá mức độ tham gia buổi học', 100, 0.20),
('TC02', N'Mức độ tập trung', N'Tập trung', N'Đánh giá sự tập trung trong giờ học', 100, 0.20),
('TC03', N'Hoàn thành bài tập', N'Hoàn thành', N'Đánh giá tỷ lệ hoàn thành bài tập', 100, 0.20),
('TC04', N'Tham gia thảo luận', N'Thảo luận', N'Đánh giá mức độ tham gia thảo luận', 10, 0.15),
('TC05', N'Tính chủ động', N'Chủ động', N'Đánh giá sự chủ động trong học tập', 100, 0.10),
('TC06', N'Làm việc nhóm', N'Làm việc nhóm', N'Đánh giá khả năng làm việc nhóm', 100, 0.10),
('TC07', N'Tôn trọng', N'Tôn trọng', N'Đánh giá thái độ tôn trọng', 100, 0.05),
('TC08', N'Kỷ luật', N'Kỷ luật', N'Đánh giá tuân thủ kỷ luật', 100, 0.05);

-- Thêm dữ liệu vào bảng LopHocPhan (Thêm 20 lớp học phần)
INSERT INTO LopHocPhan (maLHP, maMonHoc, maGiangVien, hocKy, namHoc, siSoToiDa, soSinhVienHienTai, ngayBatDau, ngayKetThuc) VALUES
('LHP01', 'MH01', 'GV01', '1', '2023-2024', 60, 10, '2023-09-01', '2023-12-15'),
('LHP02', 'MH02', 'GV02', '1', '2023-2024', 60, 10, '2023-09-01', '2023-12-15'),
('LHP03', 'MH03', 'GV04', '1', '2023-2024', 60, 10, '2023-09-01', '2023-12-15'),
('LHP04', 'MH04', 'GV03', '1', '2023-2024', 60, 10, '2023-09-01', '2023-12-15'),
('LHP05', 'MH05', 'GV07', '1', '2023-2024', 60, 10, '2023-09-01', '2023-12-15'),
('LHP06', 'MH06', 'GV08', '2', '2023-2024', 60, 10, '2024-02-01', '2024-05-15'),
('LHP07', 'MH07', 'GV12', '2', '2023-2024', 60, 10, '2024-02-01', '2024-05-15'),
('LHP08', 'MH08', 'GV11', '2', '2023-2024', 60, 10, '2024-02-01', '2024-05-15'),
('LHP09', 'MH09', 'GV13', '2', '2023-2024', 60, 10, '2024-02-01', '2024-05-15'),
('LHP10', 'MH10', 'GV17', '2', '2023-2024', 60, 10, '2024-02-01', '2024-05-15'),
('LHP11', 'MH11', 'GV05', '1', '2024-2025', 60, 10, '2024-09-01', '2024-12-15'),
('LHP12', 'MH12', 'GV15', '1', '2024-2025', 60, 10, '2024-09-01', '2024-12-15'),
('LHP13', 'MH13', 'GV14', '1', '2024-2025', 60, 10, '2024-09-01', '2024-12-15'),
('LHP14', 'MH14', 'GV16', '1', '2024-2025', 60, 10, '2024-09-01', '2024-12-15'),
('LHP15', 'MH15', 'GV20', '1', '2024-2025', 60, 10, '2024-09-01', '2024-12-15'),
('LHP16', 'MH01', 'GV01', '2', '2024-2025', 60, 10, '2025-02-01', '2025-05-15'),
('LHP17', 'MH02', 'GV02', '2', '2024-2025', 60, 10, '2025-02-01', '2025-05-15'),
('LHP18', 'MH03', 'GV04', '2', '2024-2025', 60, 10, '2025-02-01', '2025-05-15'),
('LHP19', 'MH04', 'GV03', '2', '2024-2025', 60, 10, '2025-02-01', '2025-05-15'),
('LHP20', 'MH05', 'GV07', '2', '2024-2025', 60, 10, '2025-02-01', '2025-05-15');

-- Thêm dữ liệu vào bảng DangKyHocPhan
INSERT INTO DangKyHocPhan (maSinhVien, maLHP, ngayDangKy, trangThai, diemGiuaKy, diemCuoiKy, diemThucHanh, diemTong) VALUES
-- 50 bản ghi trạng thái Hoàn thành (phân bổ đều cho các sinh viên và học phần)
('SV001', 'LHP01', '2023-08-20', N'Hoàn thành', 8.0, 8.5, 7.5, 8.2), -- Kỹ thuật xây dựng
('SV002', 'LHP01', '2023-08-20', N'Hoàn thành', 7.5, 7.0, 8.0, 7.5),
('SV003', 'LHP01', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV004', 'LHP01', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV005', 'LHP01', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV006', 'LHP02', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 8.0, 8.2), -- Quản trị marketing
('SV007', 'LHP02', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 7.5, 7.5),
('SV008', 'LHP02', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV009', 'LHP02', '2023-08-20', N'Hoàn thành', 7.0, 7.0, 7.5, 7.2),
('SV010', 'LHP02', '2023-08-20', N'Hoàn thành', 8.5, 8.5, 8.0, 8.3),
('SV011', 'LHP03', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9), -- Lập trình Java
('SV012', 'LHP03', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 8.0, 7.7),
('SV013', 'LHP03', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV014', 'LHP03', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV015', 'LHP03', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV016', 'LHP04', '2023-08-20', N'Hoàn thành', 8.0, 8.5, 7.5, 8.2), -- Công nghệ ô tô
('SV017', 'LHP04', '2023-08-20', N'Hoàn thành', 7.5, 7.0, 8.0, 7.5),
('SV018', 'LHP04', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV019', 'LHP04', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV020', 'LHP04', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV021', 'LHP05', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 8.0, 8.2), -- Quản lý chuỗi cung ứng
('SV022', 'LHP05', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 7.5, 7.5),
('SV023', 'LHP05', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV024', 'LHP05', '2023-08-20', N'Hoàn thành', 7.0, 7.0, 7.5, 7.2),
('SV025', 'LHP05', '2023-08-20', N'Hoàn thành', 8.5, 8.5, 8.0, 8.3),
('SV026', 'LHP06', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9), -- Điện tử viễn thông
('SV027', 'LHP06', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 8.0, 7.7),
('SV028', 'LHP06', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV029', 'LHP06', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV030', 'LHP06', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV031', 'LHP07', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 8.0, 8.2), -- Kế toán tài chính
('SV032', 'LHP07', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 7.5, 7.5),
('SV033', 'LHP07', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV034', 'LHP07', '2023-08-20', N'Hoàn thành', 7.0, 7.0, 7.5, 7.2),
('SV035', 'LHP07', '2023-08-20', N'Hoàn thành', 8.5, 8.5, 8.0, 8.3),
('SV036', 'LHP08', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9), -- Kinh tế xây dựng
('SV037', 'LHP08', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 8.0, 7.7),
('SV038', 'LHP08', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV039', 'LHP08', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV040', 'LHP08', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),
('SV041', 'LHP09', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 8.0, 8.2), -- Cơ điện tử
('SV042', 'LHP09', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 7.5, 7.5),
('SV043', 'LHP09', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 8.0, 8.0),
('SV044', 'LHP09', '2023-08-20', N'Hoàn thành', 7.0, 7.0, 7.5, 7.2),
('SV045', 'LHP09', '2023-08-20', N'Hoàn thành', 8.5, 8.5, 8.0, 8.3),
('SV046', 'LHP10', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9), -- Quản lý vận tải
('SV047', 'LHP10', '2023-08-20', N'Hoàn thành', 7.5, 7.5, 8.0, 7.7),
('SV048', 'LHP10', '2023-08-20', N'Hoàn thành', 8.5, 8.0, 7.0, 7.8),
('SV049', 'LHP10', '2023-08-20', N'Hoàn thành', 7.0, 7.5, 8.5, 7.7),
('SV050', 'LHP10', '2023-08-20', N'Hoàn thành', 8.0, 8.0, 7.5, 7.9),

-- 50 bản ghi trạng thái Đang học (phân bổ đều cho các sinh viên và học phần)
('SV001', 'LHP11', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL), -- Toán cao cấp
('SV002', 'LHP14', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL), -- Sức bền vật liệu
('SV003', 'LHP08', '2024-08-20', N'Đang học', 8.5, NULL, 7.0, NULL), -- Kinh tế xây dựng
('SV004', 'LHP14', '2024-08-20', N'Đang học', 7.0, NULL, 8.5, NULL),
('SV005', 'LHP11', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV006', 'LHP12', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL), -- Vật lý kỹ thuật
('SV007', 'LHP15', '2024-08-20', N'Đang học', 7.5, NULL, 7.5, NULL), -- Triết học
('SV008', 'LHP07', '2024-08-20', N'Đang học', 8.0, NULL, 8.0, NULL), -- Kế toán tài chính
('SV009', 'LHP12', '2024-08-20', N'Đang học', 7.0, NULL, 7.5, NULL),
('SV010', 'LHP15', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV011', 'LHP13', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL), -- Tin học cơ bản
('SV012', 'LHP11', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL),
('SV013', 'LHP13', '2024-08-20', N'Đang học', 8.5, NULL, 7.0, NULL),
('SV014', 'LHP11', '2024-08-20', N'Đang học', 7.0, NULL, 8.5, NULL),
('SV015', 'LHP13', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV016', 'LHP14', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV017', 'LHP12', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL),
('SV018', 'LHP14', '2024-08-20', N'Đang học', 8.5, NULL, 7.0, NULL),
('SV019', 'LHP12', '2024-08-20', N'Đang học', 7.0, NULL, 8.5, NULL),
('SV020', 'LHP14', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV021', 'LHP15', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV022', 'LHP12', '2024-08-20', N'Đang học', 7.5, NULL, 7.5, NULL),
('SV023', 'LHP15', '2024-08-20', N'Đang học', 8.0, NULL, 8.0, NULL),
('SV024', 'LHP12', '2024-08-20', N'Đang học', 7.0, NULL, 7.5, NULL),
('SV025', 'LHP15', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV026', 'LHP14', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV027', 'LHP12', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL),
('SV028', 'LHP14', '2024-08-20', N'Đang học', 8.5, NULL, 7.0, NULL),
('SV029', 'LHP12', '2024-08-20', N'Đang học', 7.0, NULL, 8.5, NULL),
('SV030', 'LHP14', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV031', 'LHP15', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV032', 'LHP12', '2024-08-20', N'Đang học', 7.5, NULL, 7.5, NULL),
('SV033', 'LHP15', '2024-08-20', N'Đang học', 8.0, NULL, 8.0, NULL),
('SV034', 'LHP12', '2024-08-20', N'Đang học', 7.0, NULL, 7.5, NULL),
('SV035', 'LHP15', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV036', 'LHP14', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV037', 'LHP11', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL),
('SV038', 'LHP14', '2024-08-20', N'Đang học', 8.5, NULL, 7.0, NULL),
('SV039', 'LHP11', '2024-08-20', N'Đang học', 7.0, NULL, 8.5, NULL),
('SV040', 'LHP14', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV041', 'LHP12', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV042', 'LHP14', '2024-08-20', N'Đang học', 7.5, NULL, 7.5, NULL),
('SV043', 'LHP12', '2024-08-20', N'Đang học', 8.0, NULL, 8.0, NULL),
('SV044', 'LHP14', '2024-08-20', N'Đang học', 7.0, NULL, 7.5, NULL),
('SV045', 'LHP12', '2024-08-20', N'Đang học', 8.5, NULL, 8.0, NULL),
('SV046', 'LHP15', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),
('SV047', 'LHP12', '2024-08-20', N'Đang học', 7.5, NULL, 8.0, NULL),
('SV048', 'LHP15', '2024-08-20', N'Đang học', 8.5, NULL, 7.0, NULL),
('SV049', 'LHP12', '2024-08-20', N'Đang học', 7.0, NULL, 8.5, NULL),
('SV050', 'LHP15', '2024-08-20', N'Đang học', 8.0, NULL, 7.5, NULL),

-- 50 bản ghi trạng thái Đã hủy (phân bổ đều cho các sinh viên và học phần)
('SV001', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL), -- Sức bền vật liệu
('SV002', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL), -- Toán cao cấp
('SV003', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV004', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV005', 'LHP08', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL), -- Kinh tế xây dựng
('SV006', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL), -- Triết học
('SV007', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL), -- Vật lý kỹ thuật
('SV008', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV009', 'LHP07', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL), -- Kế toán tài chính
('SV010', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV011', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV012', 'LHP13', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL), -- Tin học cơ bản
('SV013', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV014', 'LHP13', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV015', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV016', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV017', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV018', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV019', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV020', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV021', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV022', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV023', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV024', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV025', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV026', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV027', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV028', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV029', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV030', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV031', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV032', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV033', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV034', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV035', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV036', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV037', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV038', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV039', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV040', 'LHP11', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV041', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV042', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV043', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV044', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV045', 'LHP14', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV046', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV047', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV048', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV049', 'LHP15', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL),
('SV050', 'LHP12', '2024-08-20', N'Đã hủy', NULL, NULL, NULL, NULL);
GO
-- Thêm dữ liệu vào bảng BuoiHoc (Thêm 40 buổi học cho các lớp học phần)
INSERT INTO BuoiHoc (maLHP, ngayHoc, gioBatDau, gioKetThuc, phongHoc, chuDe, trangThai) VALUES
('LHP01', '2023-09-19', '07:30:00', '09:30:00', 'P101', N'Thiết kế nền móng', N'Đã diễn ra'),
('LHP01', '2023-09-26', '07:30:00', '09:30:00', 'P101', N'Vật liệu xây dựng', N'Đã diễn ra'),
('LHP02', '2023-09-20', '09:45:00', '11:45:00', 'P102', N'Nghiên cứu thị trường', N'Đã diễn ra'),
('LHP02', '2023-09-27', '09:45:00', '11:45:00', 'P102', N'Quảng cáo', N'Đã diễn ra'),
('LHP03', '2023-09-21', '13:30:00', '15:30:00', 'P103', N'Lập trình hướng đối tượng', N'Đã diễn ra'),
('LHP03', '2023-09-28', '13:30:00', '15:30:00', 'P103', N'Xử lý ngoại lệ', N'Đã diễn ra'),
('LHP04', '2024-09-19', '07:30:00', '09:30:00', 'P104', N'Hệ thống truyền động', N'Chưa diễn ra'),
('LHP04', '2024-09-26', '07:30:00', '09:30:00', 'P104', N'Bảo trì ô tô', N'Chưa diễn ra'),
('LHP05', '2023-09-20', '09:45:00', '11:45:00', 'P105', N'Vận tải logistics', N'Đã diễn ra'),
('LHP05', '2023-09-27', '09:45:00', '11:45:00', 'P105', N'Tối ưu hóa chuỗi cung ứng', N'Đã diễn ra'),
('LHP06', '2024-02-19', '07:30:00', '09:30:00', 'P106', N'Tín hiệu số', N'Đã diễn ra'),
('LHP06', '2024-02-26', '07:30:00', '09:30:00', 'P106', N'Truyền dữ liệu', N'Đã diễn ra'),
('LHP07', '2024-02-20', '09:45:00', '11:45:00', 'P107', N'Kế toán chi phí', N'Đã diễn ra'),
('LHP07', '2024-02-27', '09:45:00', '11:45:00', 'P107', N'Báo cáo tài chính', N'Đã diễn ra'),
('LHP08', '2024-02-21', '13:30:00', '15:30:00', 'P108', N'Quản lý dự án xây dựng', N'Đã diễn ra'),
('LHP08', '2024-02-28', '13:30:00', '15:30:00', 'P108', N'Định giá công trình', N'Đã diễn ra'),
('LHP09', '2024-02-19', '07:30:00', '09:30:00', 'P109', N'Robot công nghiệp', N'Đã diễn ra'),
('LHP09', '2024-02-26', '07:30:00', '09:30:00', 'P109', N'Tự động hóa', N'Đã diễn ra'),
('LHP10', '2024-02-20', '09:45:00', '11:45:00', 'P110', N'Quản lý cảng', N'Đã diễn ra'),
('LHP10', '2024-02-27', '09:45:00', '11:45:00', 'P110', N'Vận tải đa phương thức', N'Đã diễn ra');
-- Thêm dữ liệu vào bảng DiemDanh (Điểm danh cho một số buổi học)
INSERT INTO DiemDanh (maSinhVien, maBuoi, trangThai, thoiGianGhi, ghiChu) VALUES
-- LHP01
('SV001', 41, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV002', 41, N'Vắng mặt', '2023-09-19 07:30:00', N'Không có phép'),
('SV003', 41, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV004', 41, N'Có mặt', '2023-09-19 07:30:00', NULL),
('SV005', 41, N'Có phép', '2023-09-19 07:30:00', N'Xin nghỉ ốm'),
('SV001', 42, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV002', 42, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV003', 42, N'Vắng mặt', '2023-09-26 07:30:00', N'Không có phép'),
('SV004', 42, N'Có mặt', '2023-09-26 07:30:00', NULL),
('SV005', 42, N'Có mặt', '2023-09-26 07:30:00', NULL),
-- LHP02
('SV006', 43, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV007', 43, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV008', 43, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV009', 43, N'Vắng mặt', '2023-09-20 09:45:00', N'Không có phép'),
('SV010', 43, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV006', 44, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV007', 44, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV008', 44, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV009', 44, N'Có phép', '2023-09-27 09:45:00', N'Xin nghỉ gia đình'),
('SV010', 44, N'Có mặt', '2023-09-27 09:45:00', NULL),
-- LHP03
('SV011', 45, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV012', 45, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV013', 45, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV014', 45, N'Vắng mặt', '2023-09-21 13:30:00', N'Không có phép'),
('SV015', 45, N'Có mặt', '2023-09-21 13:30:00', NULL),
('SV011', 46, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV012', 46, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV013', 46, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV014', 46, N'Có mặt', '2023-09-28 13:30:00', NULL),
('SV015', 46, N'Có mặt', '2023-09-28 13:30:00', NULL),
-- LHP05
('SV021', 47, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV022', 47, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV023', 47, N'Vắng mặt', '2023-09-20 09:45:00', N'Không có phép'),
('SV024', 47, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV025', 47, N'Có mặt', '2023-09-20 09:45:00', NULL),
('SV021', 48, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV022', 48, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV023', 48, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV024', 48, N'Có mặt', '2023-09-27 09:45:00', NULL),
('SV025', 48, N'Có mặt', '2023-09-27 09:45:00', NULL),

-- LHP06 (đã có dữ liệu, bổ sung thêm để kiểm tra)
('SV026', 51, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV027', 51, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV028', 51, N'Vắng mặt', '2024-02-19 07:30:00', N'Không có phép'),
('SV029', 51, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV030', 51, N'Có phép', '2024-02-19 07:30:00', N'Xin nghỉ ốm'),
('SV026', 52, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV027', 52, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV028', 52, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV029', 52, N'Vắng mặt', '2024-02-26 07:30:00', N'Không có phép'),
('SV030', 52, N'Có mặt', '2024-02-26 07:30:00', NULL),
-- LHP07
('SV031', 53, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV032', 53, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV033', 53, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV034', 53, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV035', 53, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV031', 54, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV032', 54, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV033', 54, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV034', 54, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV035', 54, N'Có mặt', '2024-02-27 09:45:00', NULL),
-- LHP08
('SV036', 55, N'Có mặt', '2024-02-21 13:30:00', NULL),
('SV037', 55, N'Có mặt', '2024-02-21 13:30:00', NULL),
('SV038', 55, N'Vắng mặt', '2024-02-21 13:30:00', N'Không có phép'),
('SV039', 55, N'Có mặt', '2024-02-21 13:30:00', NULL),
('SV040', 55, N'Có mặt', '2024-02-21 13:30:00', NULL),
('SV036', 56, N'Có mặt', '2024-02-28 13:30:00', NULL),
('SV037', 56, N'Có mặt', '2024-02-28 13:30:00', NULL),
('SV038', 56, N'Có mặt', '2024-02-28 13:30:00', NULL),
('SV039', 56, N'Vắng mặt', '2024-02-28 13:30:00', N'Không có phép'),
('SV040', 56, N'Có mặt', '2024-02-28 13:30:00', NULL),
-- LHP09
('SV041', 57, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV042', 57, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV043', 57, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV044', 57, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV045', 57, N'Có mặt', '2024-02-19 07:30:00', NULL),
('SV041', 58, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV042', 58, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV043', 58, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV044', 58, N'Có mặt', '2024-02-26 07:30:00', NULL),
('SV045', 58, N'Có mặt', '2024-02-26 07:30:00', NULL),
-- LHP10
('SV046', 59, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV047', 59, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV048', 59, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV049', 59, N'Vắng mặt', '2024-02-20 09:45:00', N'Không có phép'),
('SV050', 59, N'Có mặt', '2024-02-20 09:45:00', NULL),
('SV046', 60, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV047', 60, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV048', 60, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV049', 60, N'Có mặt', '2024-02-27 09:45:00', NULL),
('SV050', 60, N'Có mặt', '2024-02-27 09:45:00', NULL);

-- Thêm dữ liệu vào bảng DanhGiaThaiDoHocTap (Đánh giá thái độ học tập)
INSERT INTO DanhGiaThaiDoHocTap (maSinhVien, maLHP, ngayDanhGia, nguoiDanhGia, tyLeThamGia, mucDoTapTrung, hoanThanhBaiTap, thamGiaThaoLuan, tinhChuDong, lamViecNhom, tonTrong, ghiChu) VALUES
('SV016', 'LHP04', '2023-12-10', 'GV03', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất tích cực'),
('SV017', 'LHP04', '2023-12-10', 'GV03', 80, N'Khá', 85, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV018', 'LHP04', '2023-12-10', 'GV03', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực tham gia'),
('SV019', 'LHP04', '2023-12-10', 'GV03', 60, N'Kém', 70, 5, N'Thụ động', N'Kém', N'Trung bình', N'Cần cải thiện'),
('SV020', 'LHP04', '2023-12-10', 'GV03', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt'),
('SV021', 'LHP05', '2023-12-10', 'GV07', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV022', 'LHP05', '2023-12-10', 'GV07', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV023', 'LHP05', '2023-12-10', 'GV07', 70, N'Trung bình', 75, 6, N'Thụ động', N'Trung bình', N'Trung bình', N'Vắng một số buổi'),
('SV024', 'LHP05', '2023-12-10', 'GV07', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV025', 'LHP05', '2023-12-10', 'GV07', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', NULL),
('SV026', 'LHP06', '2024-05-10', 'GV08', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt'),
('SV027', 'LHP06', '2024-05-10', 'GV08', 80, N'Khá', 85, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV028', 'LHP06', '2024-05-10', 'GV08', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực tham gia'),
('SV029', 'LHP06', '2024-05-10', 'GV08', 60, N'Kém', 70, 5, N'Thụ động', N'Kém', N'Trung bình', N'Cần cải thiện'),
('SV030', 'LHP06', '2024-05-10', 'GV08', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt'),
('SV031', 'LHP07', '2024-05-10', 'GV12', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV032', 'LHP07', '2024-05-10', 'GV12', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV033', 'LHP07', '2024-05-10', 'GV12', 70, N'Trung bình', 75, 6, N'Thụ động', N'Trung bình', N'Trung bình', N'Vắng một số buổi'),
('SV034', 'LHP07', '2024-05-10', 'GV12', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV035', 'LHP07', '2024-05-10', 'GV12', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', NULL),
('SV036', 'LHP08', '2024-05-10', 'GV11', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt'),
('SV037', 'LHP08', '2024-05-10', 'GV11', 80, N'Khá', 85, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV038', 'LHP08', '2024-05-10', 'GV11', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực tham gia'),
('SV039', 'LHP08', '2024-05-10', 'GV11', 60, N'Kém', 70, 5, N'Thụ động', N'Kém', N'Trung bình', N'Cần cải thiện'),
('SV040', 'LHP08', '2024-05-10', 'GV11', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt'),
('SV041', 'LHP09', '2024-05-10', 'GV13', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', N'Rất xuất sắc'),
('SV042', 'LHP09', '2024-05-10', 'GV13', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV043', 'LHP09', '2024-05-10', 'GV13', 70, N'Trung bình', 75, 6, N'Thụ động', N'Trung bình', N'Trung bình', N'Vắng một số buổi'),
('SV044', 'LHP09', '2024-05-10', 'GV13', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực'),
('SV045', 'LHP09', '2024-05-10', 'GV13', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', NULL),
('SV046', 'LHP10', '2024-05-10', 'GV17', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt'),
('SV047', 'LHP10', '2024-05-10', 'GV17', 80, N'Khá', 85, 7, N'Trung bình', N'Khá', N'Khá', N'Ổn định'),
('SV048', 'LHP10', '2024-05-10', 'GV17', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', N'Tích cực tham gia'),
('SV049', 'LHP10', '2024-05-10', 'GV17', 60, N'Kém', 70, 5, N'Thụ động', N'Kém', N'Trung bình', N'Cần cải thiện'),
('SV050', 'LHP10', '2024-05-10', 'GV17', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', N'Rất tốt');

-- Thêm dữ liệu vào bảng ViPhamKyLuat (Một số vi phạm)
INSERT INTO ViPhamKyLuat (maSinhVien, maLHP, ngayViPham, loaiViPham, mucDoViPham, bienPhapXuLy, diemTru, nguoiXuLy, trangThai, ghiChu) VALUES
('SV019', 'LHP04', '2023-11-20', N'Sao chép bài tập', N'Trung bình', N'Cảnh cáo', 10, 'GV03', N'Đã xử lý', N'Đã nộp lại bài'),
('SV023', 'LHP05', '2023-10-15', N'Gây rối trong lớp', N'Nghiêm trọng', N'Đình chỉ học 1 tuần', 20, 'GV07', N'Đã xử lý', N'Cam kết không tái phạm'),
('SV029', 'LHP06', '2024-03-10', N'Vi phạm nội quy thi', N'Rất nghiêm trọng', N'Hủy kết quả thi', 30, 'GV08', N'Đã xử lý', N'Đã thi lại'),
('SV039', 'LHP08', '2024-03-05', N'Vắng mặt không phép', N'Trung bình', N'Cảnh cáo', 10, 'GV11', N'Đã xử lý', N'Vắng 2 buổi liên tiếp'),
('SV049', 'LHP10', '2024-03-15', N'Sử dụng điện thoại trong giờ', N'Nhẹ', N'Nhắc nhở', 5, 'GV17', N'Đã xử lý', N'Cam kết tuân thủ');

-- Thêm dữ liệu vào bảng DiemRenLuyen (Điểm rèn luyện cho sinh viên)
INSERT INTO DiemRenLuyen (maSinhVien, hocKy, namHoc, diemTuDanhGia, diemLop, diemKhoa, diemCuoiCung, xepLoai, nguoiDanhGia, ngayDanhGia, coHocBong, loaiHocBong, giaTriHocBong, ghiChu) VALUES
('SV016', '1', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV03', '2023-12-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV017', '1', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV03', '2023-12-20', 0, NULL, NULL, NULL),
('SV018', '1', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV03', '2023-12-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV019', '1', '2023-2024', 65, 60, 62, 52, N'Trung bình', 'GV03', '2023-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV020', '1', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV03', '2023-12-20', 1, N'Khá', 5000000, N'Rất tốt'),
('SV021', '1', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV07', '2023-12-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV022', '1', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV07', '2023-12-20', 0, NULL, NULL, NULL),
('SV023', '1', '2023-2024', 75, 70, 72, 52, N'Trung bình', 'GV07', '2023-12-20', 0, NULL, NULL, N'Có vi phạm'),
('SV024', '1', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV07', '2023-12-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV025', '1', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV07', '2023-12-20', 0, NULL, NULL, NULL),
('SV026', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV08', '2024-05-20', 1, N'Khá', 5000000, N'Rất tốt'),
('SV027', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV08', '2024-05-20', 0, NULL, NULL, NULL),
('SV028', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV08', '2024-05-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV029', '2', '2023-2024', 65, 60, 62, 32, N'Yếu', 'GV08', '2024-05-20', 0, NULL, NULL, N'Có vi phạm nghiêm trọng'),
('SV030', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV08', '2024-05-20', 1, N'Khá', 5000000, N'Rất tốt'),
('SV031', '2', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV12', '2024-05-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV032', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV12', '2024-05-20', 0, NULL, NULL, NULL),
('SV033', '2', '2023-2024', 75, 70, 72, 72, N'Khá', 'GV12', '2024-05-20', 0, NULL, NULL, NULL),
('SV034', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV12', '2024-05-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV035', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV12', '2024-05-20', 0, NULL, NULL, NULL),
('SV036', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV11', '2024-05-20', 1, N'Khá', 5000000, N'Rất tốt'),
('SV037', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV11', '2024-05-20', 0, NULL, NULL, NULL),
('SV038', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV11', '2024-05-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV039', '2', '2023-2024', 65, 60, 62, 52, N'Trung bình', 'GV11', '2024-05-20', 0, NULL, NULL, N'Có vi phạm'),
('SV040', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV11', '2024-05-20', 1, N'Khá', 5000000, N'Rất tốt'),
('SV041', '2', '2023-2024', 95, 90, 92, 92, N'Xuất sắc', 'GV13', '2024-05-20', 1, N'Xuất sắc', 7000000, N'Rất xuất sắc'),
('SV042', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV13', '2024-05-20', 0, NULL, NULL, NULL),
('SV043', '2', '2023-2024', 75, 70, 72, 72, N'Khá', 'GV13', '2024-05-20', 0, NULL, NULL, NULL),
('SV044', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV13', '2024-05-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV045', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV13', '2024-05-20', 0, NULL, NULL, NULL),
('SV046', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV17', '2024-05-20', 1, N'Khá', 5000000, N'Rất tốt'),
('SV047', '2', '2023-2024', 85, 80, 82, 82, N'Khá', 'GV17', '2024-05-20', 0, NULL, NULL, NULL),
('SV048', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV17', '2024-05-20', 1, N'Khá', 5000000, N'Tích cực'),
('SV049', '2', '2023-2024', 65, 60, 62, 52, N'Trung bình', 'GV17', '2024-05-20', 0, NULL, NULL, N'Có vi phạm'),
('SV050', '2', '2023-2024', 90, 85, 88, 87, N'Tốt', 'GV17', '2024-05-20', 1, N'Khá', 5000000, N'Rất tốt');

-- Thêm dữ liệu vào bảng ChiTietDanhGia (Chi tiết đánh giá theo tiêu chí)
INSERT INTO ChiTietDanhGia (maDanhGia, maTieuChi, diem, ghiChu) VALUES
(16, 'TC01', 95, N'Tham gia xuất sắc'), (16, 'TC02', 90, N'Tập trung xuất sắc'), (16, 'TC03', 90, N'Hoàn thành bài tập xuất sắc'),
(17, 'TC01', 80, N'Tham gia ổn'), (17, 'TC02', 85, N'Tập trung khá'), (17, 'TC03', 85, N'Hoàn thành bài tập khá'),
(18, 'TC01', 85, N'Tham gia khá'), (18, 'TC02', 80, N'Tập trung tốt'), (18, 'TC03', 80, N'Hoàn thành bài tập tốt'),
(19, 'TC01', 60, N'Tham gia kém'), (19, 'TC02', 70, N'Tập trung kém'), (19, 'TC03', 70, N'Hoàn thành bài tập kém'),
(20, 'TC01', 90, N'Tham gia đầy đủ'), (20, 'TC02', 85, N'Tập trung tốt'), (20, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(21, 'TC01', 95, N'Tham gia xuất sắc'), (21, 'TC02', 90, N'Tập trung xuất sắc'), (21, 'TC03', 90, N'Hoàn thành bài tập xuất sắc'),
(22, 'TC01', 85, N'Tham gia khá'), (22, 'TC02', 80, N'Tập trung khá'), (22, 'TC03', 80, N'Hoàn thành bài tập khá'),
(23, 'TC01', 70, N'Tham gia chưa đều'), (23, 'TC02', 75, N'Tập trung trung bình'), (23, 'TC03', 75, N'Hoàn thành bài tập trung bình'),
(24, 'TC01', 90, N'Tham gia đầy đủ'), (24, 'TC02', 85, N'Tập trung tốt'), (24, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(25, 'TC01', 85, N'Tham gia khá'), (25, 'TC02', 80, N'Tập trung khá'), (25, 'TC03', 80, N'Hoàn thành bài tập khá'),
(26, 'TC01', 90, N'Tham gia đầy đủ'), (26, 'TC02', 85, N'Tập trung tốt'), (26, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(27, 'TC01', 80, N'Tham gia ổn'), (27, 'TC02', 85, N'Tập trung khá'), (27, 'TC03', 85, N'Hoàn thành bài tập khá'),
(28, 'TC01', 85, N'Tham gia khá'), (28, 'TC02', 80, N'Tập trung tốt'), (28, 'TC03', 80, N'Hoàn thành bài tập tốt'),
(29, 'TC01', 60, N'Tham gia kém'), (29, 'TC02', 70, N'Tập trung kém'), (29, 'TC03', 70, N'Hoàn thành bài tập kém'),
(30, 'TC01', 90, N'Tham gia đầy đủ'), (30, 'TC02', 85, N'Tập trung tốt'), (30, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(31, 'TC01', 95, N'Tham gia xuất sắc'), (31, 'TC02', 90, N'Tập trung xuất sắc'), (31, 'TC03', 90, N'Hoàn thành bài tập xuất sắc'),
(32, 'TC01', 85, N'Tham gia khá'), (32, 'TC02', 80, N'Tập trung khá'), (32, 'TC03', 80, N'Hoàn thành bài tập khá'),
(33, 'TC01', 70, N'Tham gia chưa đều'), (33, 'TC02', 75, N'Tập trung trung bình'), (33, 'TC03', 75, N'Hoàn thành bài tập trung bình'),
(34, 'TC01', 90, N'Tham gia đầy đủ'), (34, 'TC02', 85, N'Tập trung tốt'), (34, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(35, 'TC01', 85, N'Tham gia khá'), (35, 'TC02', 80, N'Tập trung khá'), (35, 'TC03', 80, N'Hoàn thành bài tập khá'),
(36, 'TC01', 90, N'Tham gia đầy đủ'), (36, 'TC02', 85, N'Tập trung tốt'), (36, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(37, 'TC01', 80, N'Tham gia ổn'), (37, 'TC02', 85, N'Tập trung khá'), (37, 'TC03', 85, N'Hoàn thành bài tập khá'),
(38, 'TC01', 85, N'Tham gia khá'), (38, 'TC02', 80, N'Tập trung tốt'), (38, 'TC03', 80, N'Hoàn thành bài tập tốt'),
(39, 'TC01', 60, N'Tham gia kém'), (39, 'TC02', 70, N'Tập trung kém'), (39, 'TC03', 70, N'Hoàn thành bài tập kém'),
(40, 'TC01', 90, N'Tham gia đầy đủ'), (40, 'TC02', 85, N'Tập trung tốt'), (40, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(41, 'TC01', 95, N'Tham gia xuất sắc'), (41, 'TC02', 90, N'Tập trung xuất sắc'), (41, 'TC03', 90, N'Hoàn thành bài tập xuất sắc'),
(42, 'TC01', 85, N'Tham gia khá'), (42, 'TC02', 80, N'Tập trung khá'), (42, 'TC03', 80, N'Hoàn thành bài tập khá'),
(43, 'TC01', 70, N'Tham gia chưa đều'), (43, 'TC02', 75, N'Tập trung trung bình'), (43, 'TC03', 75, N'Hoàn thành bài tập trung bình'),
(44, 'TC01', 90, N'Tham gia đầy đủ'), (44, 'TC02', 85, N'Tập trung tốt'), (44, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(45, 'TC01', 85, N'Tham gia khá'), (45, 'TC02', 80, N'Tập trung khá'), (45, 'TC03', 80, N'Hoàn thành bài tập khá'),
(46, 'TC01', 90, N'Tham gia đầy đủ'), (46, 'TC02', 85, N'Tập trung tốt'), (46, 'TC03', 85, N'Hoàn thành bài tập tốt'),
(47, 'TC01', 80, N'Tham gia ổn'), (47, 'TC02', 85, N'Tập trung khá'), (47, 'TC03', 85, N'Hoàn thành bài tập khá'),
(48, 'TC01', 85, N'Tham gia khá'), (48, 'TC02', 80, N'Tập trung tốt'), (48, 'TC03', 80, N'Hoàn thành bài tập tốt'),
(49, 'TC01', 60, N'Tham gia kém'), (49, 'TC02', 70, N'Tập trung kém'), (49, 'TC03', 70, N'Hoàn thành bài tập kém'),
(50, 'TC01', 90, N'Tham gia đầy đủ'), (50, 'TC02', 85, N'Tập trung tốt'), (50, 'TC03', 85, N'Hoàn thành bài tập tốt');

-- 1. Liệt kê tất cả sinh viên trong hệ thống kèm thông tin lớp và ngành học
SELECT sv.maSinhVien, sv.hoTen, sv.gioiTinh, sv.email, 
       l.tenLop, n.tenNganh, k.tenKhoa
FROM SinhVien sv
JOIN Lop l ON sv.maLop = l.maLop
JOIN NganhHoc n ON sv.maNganh = n.maNganh
JOIN Khoa k ON sv.maKhoa = k.maKhoa
ORDER BY sv.maSinhVien;

-- 2. Tìm tất cả sinh viên đang học một môn học cụ thể

SELECT sv.maSinhVien, sv.hoTen, sv.email, l.tenLop
FROM SinhVien sv
JOIN DangKyHocPhan dkhp ON sv.maSinhVien = dkhp.maSinhVien
JOIN LopHocPhan lhp ON dkhp.maLHP = lhp.maLHP
JOIN MonHoc mh ON lhp.maMonHoc = mh.maMonHoc
JOIN Lop l ON sv.maLop = l.maLop
WHERE mh.tenMonHoc = N'Lập trình Java'
AND dkhp.trangThai = N'Hoàn thành'
ORDER BY sv.maSinhVien;

-- 3. Hiển thị số lượng sinh viên theo từng ngành
SELECT n.maNganh, n.tenNganh, k.tenKhoa, 
       COUNT(sv.maSinhVien) AS SoLuongSinhVien
FROM NganhHoc n
LEFT JOIN SinhVien sv ON n.maNganh = sv.maNganh
JOIN Khoa k ON n.maKhoa = k.maKhoa
GROUP BY n.maNganh, n.tenNganh, k.tenKhoa
ORDER BY SoLuongSinhVien DESC;

-- 4. Tìm các giảng viên và môn học họ đang dạy trong học kỳ hiện tại
SELECT gv.maGiangVien, gv.hoTen AS TenGiangVien, 
       mh.maMonHoc, mh.tenMonHoc, 
       lhp.maLHP, lhp.hocKy, lhp.namHoc,
       lhp.soSinhVienHienTai
FROM GiangVien gv
JOIN LopHocPhan lhp ON gv.maGiangVien = lhp.maGiangVien
JOIN MonHoc mh ON lhp.maMonHoc = mh.maMonHoc
WHERE lhp.namHoc = '2024-2025' AND lhp.hocKy = '2'
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