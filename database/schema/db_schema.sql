
CREATE DATABASE QuanLyThaiDoHocTap;
GO
USE QuanLyThaiDoHocTap;
GO

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
