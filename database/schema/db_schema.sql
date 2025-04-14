-- Tạo database
CREATE DATABASE [BTLSQL-ThaiDoHocTapSv];
GO
USE [BTLSQL-ThaiDoHocTapSv];
GO

-- Xóa các trigger trước
DROP TRIGGER IF EXISTS trg_KiemTra_SoSinhVienToiDa;
DROP TRIGGER IF EXISTS trg_KiemTra_NgayDiemDanh;
DROP TRIGGER IF EXISTS trg_KiemTra_TrangThaiSinhVien;
DROP TRIGGER IF EXISTS trg_KiemTra_DanhGiaKyHienTai;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_SinhVien;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_GiangVien;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_Khoa;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_NganhHoc;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_Lop;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_MonHoc;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_LopHocPhan;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_DangKyHocPhan;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_BuoiHoc;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_DiemDanh;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_ThaiDoHocTap;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_ViPhamKyLuat;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_Diem;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_DiemRenLuyen;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_LichHoc;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_TaiLieuHocTap;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_HocBong;
DROP TRIGGER IF EXISTS trg_KiemTra_ThoiGianDangKy;
DROP TRIGGER IF EXISTS trg_KiemTra_DiemDanh_DangKy;
DROP TRIGGER IF EXISTS trg_TinhDiemTong;
DROP TRIGGER IF EXISTS trg_CapHocBong;

-- Xóa các view và stored procedure trước
DROP VIEW IF EXISTS vw_TyLeDiemDanh;
DROP PROCEDURE IF EXISTS sp_TinhDiemRenLuyen;

-- Xóa các bảng theo thứ tự
DROP TABLE IF EXISTS HocBong;
DROP TABLE IF EXISTS DiemRenLuyen;
DROP TABLE IF EXISTS Diem;
DROP TABLE IF EXISTS ViPhamKyLuat;
DROP TABLE IF EXISTS ThaiDoHocTap;
DROP TABLE IF EXISTS DiemDanh;
DROP TABLE IF EXISTS BuoiHoc;
DROP TABLE IF EXISTS DangKyHocPhan;
DROP TABLE IF EXISTS LopHocPhan;
DROP TABLE IF EXISTS MonHoc;
DROP TABLE IF EXISTS SinhVien;
DROP TABLE IF EXISTS Lop;
DROP TABLE IF EXISTS NganhHoc;
DROP TABLE IF EXISTS GiangVien;
DROP TABLE IF EXISTS Khoa;
DROP TABLE IF EXISTS LichHoc;
DROP TABLE IF EXISTS TaiLieuHocTap;

PRINT N'Đã xóa tất cả các bảng, trigger, view và stored procedure trong database [BTLSQL-ThaiDoHocTapSv]';

-- Bảng Khoa
CREATE TABLE Khoa (
    ma_khoa VARCHAR(10) PRIMARY KEY,
    ten_khoa NVARCHAR(100) NOT NULL,
    truong_khoa NVARCHAR(100),
    mo_ta NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE()
);
GO

-- Bảng Giảng viên
CREATE TABLE GiangVien (
    ma_giang_vien VARCHAR(10) PRIMARY KEY,
    ho_ten NVARCHAR(100) NOT NULL,
    gioi_tinh NVARCHAR(10) NOT NULL CHECK (gioi_tinh IN (N'Nam', N'Nữ', N'Khác')),
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@%.%'),
    ten_dang_nhap VARCHAR(50) UNIQUE NOT NULL,
    mat_khau_bam VARCHAR(256) NOT NULL,
    so_dien_thoai VARCHAR(15) CHECK (so_dien_thoai IS NULL OR so_dien_thoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    ma_khoa VARCHAR(10) NOT NULL,
    chuc_vu NVARCHAR(50),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_khoa) REFERENCES Khoa(ma_khoa)
);
GO

-- Bảng Ngành học
CREATE TABLE NganhHoc (
    ma_nganh VARCHAR(10) PRIMARY KEY,
    ten_nganh NVARCHAR(100) NOT NULL,
    ma_khoa VARCHAR(10) NOT NULL,
    mo_ta NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_khoa) REFERENCES Khoa(ma_khoa)
);
GO

-- Bảng Lớp
CREATE TABLE Lop (
    ma_lop VARCHAR(10) PRIMARY KEY,
    ten_lop NVARCHAR(100) NOT NULL,
    ma_khoa VARCHAR(10) NOT NULL,
    ma_nganh VARCHAR(10) NOT NULL,
    ma_gvcn VARCHAR(10),
    nam_bat_dau INT NOT NULL CHECK (nam_bat_dau >= 2000 AND nam_bat_dau <= YEAR(GETDATE())),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_khoa) REFERENCES Khoa(ma_khoa),
    FOREIGN KEY (ma_nganh) REFERENCES NganhHoc(ma_nganh),
    FOREIGN KEY (ma_gvcn) REFERENCES GiangVien(ma_giang_vien)
);
GO

-- Thêm ràng buộc giảng viên chủ nhiệm
ALTER TABLE Lop ADD CONSTRAINT CHK_GVCN_Khoa
CHECK (
    ma_gvcn IS NULL OR
    EXISTS (
        SELECT 1 FROM GiangVien 
        WHERE GiangVien.ma_giang_vien = Lop.ma_gvcn 
        AND GiangVien.ma_khoa = Lop.ma_khoa
    )
);
GO

-- Bảng Sinh viên
CREATE TABLE SinhVien (
    ma_sinh_vien VARCHAR(10) PRIMARY KEY,
    ho_ten NVARCHAR(100) NOT NULL,
    ngay_sinh DATE NOT NULL CHECK (ngay_sinh < GETDATE()),
    gioi_tinh NVARCHAR(10) NOT NULL CHECK (gioi_tinh IN (N'Nam', N'Nữ', N'Khác')),
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email LIKE '%@st.utc2.edu.vn'),
    ten_dang_nhap VARCHAR(50) UNIQUE NOT NULL,
    mat_khau_bam VARCHAR(256) NOT NULL,
    so_dien_thoai VARCHAR(15) CHECK (so_dien_thoai IS NULL OR so_dien_thoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    dia_chi NVARCHAR(200),
    cccd VARCHAR(12) CHECK (cccd IS NULL OR cccd LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    thong_tin_phu_huynh NVARCHAR(200),
    ma_lop VARCHAR(10) NOT NULL,
    ma_nganh VARCHAR(10) NOT NULL,
    nam_nhap_hoc INT NOT NULL CHECK (nam_nhap_hoc >= 2000 AND nam_nhap_hoc <= YEAR(GETDATE())),
    trang_thai NVARCHAR(20) NOT NULL DEFAULT N'Đang học' CHECK (trang_thai IN (N'Đang học', N'Bảo lưu', N'Thôi học', N'Tốt nghiệp')),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_lop) REFERENCES Lop(ma_lop),
    FOREIGN KEY (ma_nganh) REFERENCES NganhHoc(ma_nganh),
    CONSTRAINT CHK_SinhVien_TuoiToiThieu CHECK (DATEDIFF(YEAR, ngay_sinh, GETDATE()) >= 16)
);
GO

-- Thêm ràng buộc sinh viên thuộc lớp
ALTER TABLE SinhVien ADD CONSTRAINT CHK_SinhVien_Nganh_Lop
CHECK (
    EXISTS (
        SELECT 1 FROM Lop 
        WHERE Lop.ma_lop = SinhVien.ma_lop 
        AND Lop.ma_nganh = SinhVien.ma_nganh
    )
);
GO

-- Bảng Môn học
CREATE TABLE MonHoc (
    ma_mon_hoc VARCHAR(10) PRIMARY KEY,
    ten_mon_hoc NVARCHAR(100) NOT NULL,
    so_tin_chi INT NOT NULL CHECK (so_tin_chi BETWEEN 1 AND 10),
    ma_khoa VARCHAR(10) NOT NULL,
    mo_ta NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_khoa) REFERENCES Khoa(ma_khoa)
);
GO

-- Bảng Lớp học phần
CREATE TABLE LopHocPhan (
    ma_lhp VARCHAR(20) PRIMARY KEY,
    ma_mon_hoc VARCHAR(10) NOT NULL,
    ma_giang_vien VARCHAR(10) NOT NULL,
    hoc_ky VARCHAR(3) NOT NULL CHECK (hoc_ky IN ('1', '2', N'Hè')),
    nam_hoc VARCHAR(9) NOT NULL CHECK (
        nam_hoc LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' AND
        CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + 1 = CAST(SUBSTRING(nam_hoc, 6, 4) AS INT)
    ),
    si_so_toi_da INT NOT NULL CHECK (si_so_toi_da > 0 AND si_so_toi_da <= 200),
    ngay_bat_dau_dang_ky DATE,
    ngay_ket_thuc_dang_ky DATE,
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_mon_hoc) REFERENCES MonHoc(ma_mon_hoc),
    FOREIGN KEY (ma_giang_vien) REFERENCES GiangVien(ma_giang_vien),
    CONSTRAINT CHK_ThoiGianDangKy CHECK (ngay_ket_thuc_dang_ky IS NULL OR ngay_ket_thuc_dang_ky > ngay_bat_dau_dang_ky)
);
GO

-- Bảng Đăng ký học phần
CREATE TABLE DangKyHocPhan (
    ma_dang_ky INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    ma_lhp VARCHAR(20) NOT NULL,
    ngay_dang_ky DATETIME NOT NULL CHECK (ngay_dang_ky <= GETDATE()),
    trang_thai NVARCHAR(20) NOT NULL CHECK (trang_thai IN (N'Đăng ký', N'Đang học', N'Hoàn thành', N'Đã hủy')),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienLopHocPhan UNIQUE (ma_sinh_vien, ma_lhp),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp)
);
GO

-- Bảng Buổi học
CREATE TABLE BuoiHoc (
    ma_buoi INT IDENTITY(1,1) PRIMARY KEY,
    ma_lhp VARCHAR(20) NOT NULL,
    ngay_hoc DATE NOT NULL,
    gio_bat_dau TIME NOT NULL,
    gio_ket_thuc TIME NOT NULL,
    phong_hoc VARCHAR(20) NOT NULL,
    chu_de NVARCHAR(200),
    trang_thai NVARCHAR(20) NOT NULL DEFAULT N'Chưa diễn ra' CHECK (trang_thai IN (N'Đã diễn ra', N'Chưa diễn ra', N'Hủy')),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    CONSTRAINT CHK_ThoiGianBuoiHoc CHECK (gio_ket_thuc > gio_bat_dau)
);
GO

-- Bảng Điểm danh
CREATE TABLE DiemDanh (
    ma_diem_danh INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    ma_buoi INT NOT NULL,
    trang_thai NVARCHAR(20) NOT NULL CHECK (trang_thai IN (N'Có mặt', N'Vắng mặt', N'Đi muộn', N'Có phép')),
    thoi_gian_ghi DATETIME NOT NULL,
    ghi_chu NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienBuoiHoc UNIQUE (ma_sinh_vien, ma_buoi),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_buoi) REFERENCES BuoiHoc(ma_buoi)
);
GO

-- Bảng Thái độ học tập
CREATE TABLE ThaiDoHocTap (
    ma_danh_gia INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    ma_lhp VARCHAR(20) NOT NULL,
    ty_le_tham_gia DECIMAL(5,2) CHECK (ty_le_tham_gia IS NULL OR ty_le_tham_gia BETWEEN 0 AND 100),
    muc_do_tap_trung NVARCHAR(20) CHECK (muc_do_tap_trung IN (N'Kém', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc')),
    hoan_thanh_bai_tap DECIMAL(5,2) CHECK (hoan_thanh_bai_tap IS NULL OR hoan_thanh_bai_tap BETWEEN 0 AND 100),
    tham_gia_thao_luan INT CHECK (tham_gia_thao_luan IS NULL OR tham_gia_thao_luan BETWEEN 0 AND 10),
    tinh_chu_dong NVARCHAR(20) CHECK (tinh_chu_dong IN (N'Thụ động', N'Trung bình', N'Chủ động')),
    lam_viec_nhom NVARCHAR(20) CHECK (lam_viec_nhom IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')),
    ton_trong NVARCHAR(20) CHECK (ton_trong IN (N'Kém', N'Trung bình', N'Khá', N'Tốt')),
    ghi_chu NVARCHAR(MAX),
    ma_nguoi_danh_gia VARCHAR(10) NOT NULL,
    ngay_danh_gia DATETIME NOT NULL,
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    FOREIGN KEY (ma_nguoi_danh_gia) REFERENCES GiangVien(ma_giang_vien)
);
GO

-- Ràng buộc cho ThaiDoHocTap
ALTER TABLE ThaiDoHocTap ADD CONSTRAINT CHK_NguoiDanhGia_La_GiangVien
CHECK (
    EXISTS (
        SELECT 1 FROM LopHocPhan
        WHERE LopHocPhan.ma_lhp = ThaiDoHocTap.ma_lhp
        AND LopHocPhan.ma_giang_vien = ThaiDoHocTap.ma_nguoi_danh_gia
    )
);
GO

ALTER TABLE ThaiDoHocTap ADD CONSTRAINT CHK_SinhVien_DaDangKy
CHECK (
    EXISTS (
        SELECT 1 FROM DangKyHocPhan
        WHERE DangKyHocPhan.ma_sinh_vien = ThaiDoHocTap.ma_sinh_vien
        AND DangKyHocPhan.ma_lhp = ThaiDoHocTap.ma_lhp
    )
);
GO

ALTER TABLE ThaiDoHocTap ADD CONSTRAINT CHK_DanhGia_SauDangKy
CHECK (
    ngay_danh_gia >= (
        SELECT MIN(ngay_dang_ky)
        FROM DangKyHocPhan
        WHERE DangKyHocPhan.ma_lhp = ThaiDoHocTap.ma_lhp
        AND DangKyHocPhan.ma_sinh_vien = ThaiDoHocTap.ma_sinh_vien
    )
);
GO

-- Bảng Vi phạm kỷ luật
CREATE TABLE ViPhamKyLuat (
    ma_vi_pham INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    ngay_vi_pham DATE NOT NULL CHECK (ngay_vi_pham <= GETDATE()),
    loai_vi_pham NVARCHAR(100) NOT NULL,
    muc_do NVARCHAR(20) NOT NULL CHECK (muc_do IN (N'Nhẹ', N'Trung bình', N'Nghiêm trọng', N'Rất nghiêm trọng')),
    bien_phap_xu_ly NVARCHAR(200),
    ma_nguoi_bao_cao VARCHAR(10) NOT NULL,
    ghi_chu NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_nguoi_bao_cao) REFERENCES GiangVien(ma_giang_vien)
);
GO

-- Bảng Điểm
CREATE TABLE Diem (
    ma_diem INT IDENTITY(1,1) PRIMARY KEY,
    ma_dang_ky INT NOT NULL,
    diem_giua_ky DECIMAL(4,2) CHECK (diem_giua_ky IS NULL OR diem_giua_ky BETWEEN 0 AND 10),
    diem_cuoi_ky DECIMAL(4,2) CHECK (diem_cuoi_ky IS NULL OR diem_cuoi_ky BETWEEN 0 AND 10),
    diem_thuc_hanh DECIMAL(4,2) CHECK (diem_thuc_hanh IS NULL OR diem_thuc_hanh BETWEEN 0 AND 10),
    diem_tong DECIMAL(4,2) CHECK (diem_tong IS NULL OR diem_tong BETWEEN 0 AND 10),
    diem_chu VARCHAR(2) CHECK (diem_chu IS NULL OR diem_chu IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F')),
    trang_thai NVARCHAR(20) NOT NULL DEFAULT N'Chờ duyệt' CHECK (trang_thai IN (N'Chờ duyệt', N'Đã duyệt')),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_DangKy UNIQUE (ma_dang_ky),
    FOREIGN KEY (ma_dang_ky) REFERENCES DangKyHocPhan(ma_dang_ky)
);
GO

-- Bảng Điểm rèn luyện
CREATE TABLE DiemRenLuyen (
    ma_diem_ren_luyen INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    hoc_ky VARCHAR(1) NOT NULL CHECK (hoc_ky IN ('1', '2')),
    nam_hoc VARCHAR(9) NOT NULL CHECK (
        nam_hoc LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' AND
        CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + 1 = CAST(SUBSTRING(nam_hoc, 6, 4) AS INT)
    ),
    diem_tu_danh_gia INT CHECK (diem_tu_danh_gia IS NULL OR diem_tu_danh_gia BETWEEN 0 AND 100),
    diem_lop INT CHECK (diem_lop IS NULL OR diem_lop BETWEEN 0 AND 100),
    diem_khoa INT CHECK (diem_khoa IS NULL OR diem_khoa BETWEEN 0 AND 100),
    diem_cuoi_cung INT NOT NULL CHECK (diem_cuoi_cung BETWEEN 0 AND 100),
    xep_loai NVARCHAR(20) NOT NULL CHECK (xep_loai IN (N'Xuất sắc', N'Tốt', N'Khá', N'Trung bình', N'Yếu', N'Kém')),
    ma_nguoi_danh_gia VARCHAR(10) NOT NULL,
    ngay_danh_gia DATE NOT NULL CHECK (ngay_danh_gia <= GETDATE()),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienHocKyNamHoc UNIQUE (ma_sinh_vien, hoc_ky, nam_hoc),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_nguoi_danh_gia) REFERENCES GiangVien(ma_giang_vien)
);
GO

-- Bảng Học bổng
CREATE TABLE HocBong (
    ma_hoc_bong INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    hoc_ky VARCHAR(1) NOT NULL CHECK (hoc_ky IN ('1', '2')),
    nam_hoc VARCHAR(9) NOT NULL CHECK (
        nam_hoc LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' AND
        CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + 1 = CAST(SUBSTRING(nam_hoc, 6, 4) AS INT)
    ),
    loai_hoc_bong NVARCHAR(50) NOT NULL CHECK (loai_hoc_bong IN (N'Xuất sắc', N'Khá')),
    gia_tri_hoc_bong DECIMAL(10,2) NOT NULL CHECK (gia_tri_hoc_bong >= 0),
    diem_ren_luyen INT NOT NULL CHECK (diem_ren_luyen BETWEEN 0 AND 100),
    diem_trung_binh DECIMAL(4,2) NOT NULL CHECK (diem_trung_binh BETWEEN 0 AND 10),
    ngay_cap DATE NOT NULL CHECK (ngay_cap <= GETDATE()),
    ghi_chu NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienHocBongHocKyNamHoc UNIQUE (ma_sinh_vien, hoc_ky, nam_hoc),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien)
);
GO

-- Bảng Lịch học
CREATE TABLE LichHoc (
    ma_lich INT IDENTITY(1,1) PRIMARY KEY,
    ma_lhp VARCHAR(20) NOT NULL,
    thu NVARCHAR(20) CHECK (thu IN (N'Thứ 2', N'Thứ 3', N'Thứ 4', N'Thứ 5', N'Thứ 6', N'Thứ 7', N'Chủ nhật')),
    gio_bat_dau TIME NOT NULL,
    gio_ket_thuc TIME NOT NULL,
    phong_hoc VARCHAR(20) NOT NULL,
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    CONSTRAINT CHK_ThoiGianLichHoc CHECK (gio_ket_thuc > gio_bat_dau)
);
GO

-- Bảng Tài liệu học tập
CREATE TABLE TaiLieuHocTap (
    ma_tai_lieu INT IDENTITY(1,1) PRIMARY KEY,
    ma_lhp VARCHAR(20) NOT NULL,
    tieu_de NVARCHAR(200) NOT NULL,
    duong_dan VARCHAR(500) NOT NULL,
    ma_nguoi_tai_len VARCHAR(10) NOT NULL,
    ngay_tai_len DATETIME DEFAULT GETDATE(),
    mo_ta NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    FOREIGN KEY (ma_nguoi_tai_len) REFERENCES GiangVien(ma_giang_vien)
);
GO

-- Trigger tự động cập nhật ngay_cap_nhat
CREATE TRIGGER trg_CapNhat_ThoiGian_SinhVien
ON SinhVien
AFTER UPDATE
AS
BEGIN
    UPDATE SinhVien
    SET ngay_cap_nhat = GETDATE()
    FROM SinhVien s
    INNER JOIN inserted i ON s.ma_sinh_vien = i.ma_sinh_vien;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_GiangVien
ON GiangVien
AFTER UPDATE
AS
BEGIN
    UPDATE GiangVien
    SET ngay_cap_nhat = GETDATE()
    FROM GiangVien gv
    INNER JOIN inserted i ON gv.ma_giang_vien = i.ma_giang_vien;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_Khoa
ON Khoa
AFTER UPDATE
AS
BEGIN
    UPDATE Khoa
    SET ngay_cap_nhat = GETDATE()
    FROM Khoa k
    INNER JOIN inserted i ON k.ma_khoa = i.ma_khoa;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_NganhHoc
ON NganhHoc
AFTER UPDATE
AS
BEGIN
    UPDATE NganhHoc
    SET ngay_cap_nhat = GETDATE()
    FROM NganhHoc nh
    INNER JOIN inserted i ON nh.ma_nganh = i.ma_nganh;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_Lop
ON Lop
AFTER UPDATE
AS
BEGIN
    UPDATE Lop
    SET ngay_cap_nhat = GETDATE()
    FROM Lop l
    INNER JOIN inserted i ON l.ma_lop = i.ma_lop;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_MonHoc
ON MonHoc
AFTER UPDATE
AS
BEGIN
    UPDATE MonHoc
    SET ngay_cap_nhat = GETDATE()
    FROM MonHoc mh
    INNER JOIN inserted i ON mh.ma_mon_hoc = i.ma_mon_hoc;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_LopHocPhan
ON LopHocPhan
AFTER UPDATE
AS
BEGIN
    UPDATE LopHocPhan
    SET ngay_cap_nhat = GETDATE()
    FROM LopHocPhan lhp
    INNER JOIN inserted i ON lhp.ma_lhp = i.ma_lhp;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_DangKyHocPhan
ON DangKyHocPhan
AFTER UPDATE
AS
BEGIN
    UPDATE DangKyHocPhan
    SET ngay_cap_nhat = GETDATE()
    FROM DangKyHocPhan dk
    INNER JOIN inserted i ON dk.ma_dang_ky = i.ma_dang_ky;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_BuoiHoc
ON BuoiHoc
AFTER UPDATE
AS
BEGIN
    UPDATE BuoiHoc
    SET ngay_cap_nhat = GETDATE()
    FROM BuoiHoc bh
    INNER JOIN inserted i ON bh.ma_buoi = i.ma_buoi;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_DiemDanh
ON DiemDanh
AFTER UPDATE
AS
BEGIN
    UPDATE DiemDanh
    SET ngay_cap_nhat = GETDATE()
    FROM DiemDanh dd
    INNER JOIN inserted i ON dd.ma_diem_danh = i.ma_diem_danh;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_ThaiDoHocTap
ON ThaiDoHocTap
AFTER UPDATE
AS
BEGIN
    UPDATE ThaiDoHocTap
    SET ngay_cap_nhat = GETDATE()
    FROM ThaiDoHocTap td
    INNER JOIN inserted i ON td.ma_danh_gia = i.ma_danh_gia;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_ViPhamKyLuat
ON ViPhamKyLuat
AFTER UPDATE
AS
BEGIN
    UPDATE ViPhamKyLuat
    SET ngay_cap_nhat = GETDATE()
    FROM ViPhamKyLuat vp
    INNER JOIN inserted i ON vp.ma_vi_pham = i.ma_vi_pham;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_Diem
ON Diem
AFTER UPDATE
AS
BEGIN
    UPDATE Diem
    SET ngay_cap_nhat = GETDATE()
    FROM Diem d
    INNER JOIN inserted i ON d.ma_diem = i.ma_diem;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_DiemRenLuyen
ON DiemRenLuyen
AFTER UPDATE
AS
BEGIN
    UPDATE DiemRenLuyen
    SET ngay_cap_nhat = GETDATE()
    FROM DiemRenLuyen drl
    INNER JOIN inserted i ON drl.ma_diem_ren_luyen = i.ma_diem_ren_luyen;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_LichHoc
ON LichHoc
AFTER UPDATE
AS
BEGIN
    UPDATE LichHoc
    SET ngay_cap_nhat = GETDATE()
    FROM LichHoc lh
    INNER JOIN inserted i ON lh.ma_lich = i.ma_lich;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_TaiLieuHocTap
ON TaiLieuHocTap
AFTER UPDATE
AS
BEGIN
    UPDATE TaiLieuHocTap
    SET ngay_cap_nhat = GETDATE()
    FROM TaiLieuHocTap tl
    INNER JOIN inserted i ON tl.ma_tai_lieu = i.ma_tai_lieu;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_HocBong
ON HocBong
AFTER UPDATE
AS
BEGIN
    UPDATE HocBong
    SET ngay_cap_nhat = GETDATE()
    FROM HocBong hb
    INNER JOIN inserted i ON hb.ma_hoc_bong = i.ma_hoc_bong;
END;
GO

-- Trigger kiểm tra số lượng sinh viên đăng ký
CREATE TRIGGER trg_KiemTra_SoSinhVienToiDa
ON DangKyHocPhan
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @ma_lhp VARCHAR(20);
    DECLARE @si_so_toi_da INT;
    DECLARE @so_luong_hien_tai INT;
    
    SELECT @ma_lhp = ma_lhp FROM inserted;
    
    SELECT @si_so_toi_da = si_so_toi_da 
    FROM LopHocPhan 
    WHERE ma_lhp = @ma_lhp;
    
    SELECT @so_luong_hien_tai = COUNT(*) 
    FROM DangKyHocPhan 
    WHERE ma_lhp = @ma_lhp AND trang_thai IN (N'Đăng ký', N'Đang học', N'Hoàn thành');
    
    IF @so_luong_hien_tai > @si_so_toi_da
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Số lượng sinh viên đăng ký đã vượt quá sĩ số tối đa của lớp học phần', 1;
    END
END;
GO

-- Trigger kiểm tra ngày điểm danh
CREATE TRIGGER trg_KiemTra_NgayDiemDanh
ON DiemDanh
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN BuoiHoc b ON i.ma_buoi = b.ma_buoi
        WHERE CAST(i.thoi_gian_ghi AS DATE) != b.ngay_hoc
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, N'Ngày điểm danh phải trùng với ngày của buổi học', 1;
    END
END;
GO

-- Trigger kiểm tra trạng thái sinh viên
CREATE TRIGGER trg_KiemTra_TrangThaiSinhVien
ON DangKyHocPhan
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN SinhVien sv ON i.ma_sinh_vien = sv.ma_sinh_vien
        WHERE sv.trang_thai = N'Thôi học' AND i.trang_thai IN (N'Đăng ký', N'Đang học')
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, N'Sinh viên đã thôi học không thể đăng ký hoặc tham gia học phần mới', 1;
    END
END;
GO

-- Trigger kiểm tra đánh giá thái độ
CREATE TRIGGER trg_KiemTra_DanhGiaKyHienTai
ON ThaiDoHocTap
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN LopHocPhan lhp ON i.ma_lhp = lhp.ma_lhp
        JOIN DangKyHocPhan dk ON dk.ma_lhp = lhp.ma_lhp AND dk.ma_sinh_vien = i.ma_sinh_vien
        WHERE i.ngay_danh_gia < dk.ngay_dang_ky OR i.ngay_danh_gia > GETDATE()
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50004, N'Đánh giá thái độ học tập phải nằm trong khoảng thời gian của kỳ học', 1;
    END
END;
GO

-- Trigger kiểm tra thời gian đăng ký
CREATE TRIGGER trg_KiemTra_ThoiGianDangKy
ON DangKyHocPhan
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN LopHocPhan lhp ON i.ma_lhp = lhp.ma_lhp
        WHERE i.ngay_dang_ky < lhp.ngay_bat_dau_dang_ky OR i.ngay_dang_ky > lhp.ngay_ket_thuc_dang_ky
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50005, N'Đăng ký học phần chỉ được thực hiện trong khoảng thời gian cho phép', 1;
    END
END;
GO

-- Trigger kiểm tra đăng ký trước điểm danh
CREATE TRIGGER trg_KiemTra_DiemDanh_DangKy
ON DiemDanh
AFTER INSERT, UPDATE
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN BuoiHoc bh ON i.ma_buoi = bh.ma_buoi
        JOIN DangKyHocPhan dk ON dk.ma_sinh_vien = i.ma_sinh_vien AND dk.ma_lhp = bh.ma_lhp
        WHERE dk.trang_thai IN (N'Đăng ký', N'Đang học', N'Hoàn thành')
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50006, N'Sinh viên chưa đăng ký học phần không thể điểm danh', 1;
    END
END;
GO

-- Trigger tính điểm tổng
CREATE TRIGGER trg_TinhDiemTong
ON Diem
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Diem
    SET diem_tong = (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5),
        diem_chu = CASE
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 9.0 THEN 'A+'
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 8.5 THEN 'A'
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 8.0 THEN 'B+'
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 7.0 THEN 'B'
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 6.5 THEN 'C+'
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 5.5 THEN 'C'
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 5.0 THEN 'D+'
            WHEN (COALESCE(diem_giua_ky, 0) * 0.3 + COALESCE(diem_thuc_hanh, 0) * 0.2 + COALESCE(diem_cuoi_ky, 0) * 0.5) >= 4.0 THEN 'D'
            ELSE 'F'
        END
    FROM Diem d
    INNER JOIN inserted i ON d.ma_diem = i.ma_diem
    WHERE i.diem_giua_ky IS NOT NULL AND i.diem_thuc_hanh IS NOT NULL AND i.diem_cuoi_ky IS NOT NULL;
END;
GO

-- Trigger tự động gán học bổng
CREATE TRIGGER trg_CapHocBong
ON DiemRenLuyen
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @ma_sinh_vien VARCHAR(10);
    DECLARE @hoc_ky VARCHAR(1);
    DECLARE @nam_hoc VARCHAR(9);
    DECLARE @diem_ren_luyen INT;
    DECLARE @diem_trung_binh DECIMAL(4,2);

    -- Lấy thông tin từ DiemRenLuyen
    SELECT @ma_sinh_vien = i.ma_sinh_vien, 
           @hoc_ky = i.hoc_ky, 
           @nam_hoc = i.nam_hoc, 
           @diem_ren_luyen = i.diem_cuoi_cung
    FROM inserted i;

    -- Tính điểm trung bình học tập
    SELECT @diem_trung_binh = AVG(d.diem_tong)
    FROM Diem d
    JOIN DangKyHocPhan dk ON d.ma_dang_ky = dk.ma_dang_ky
    JOIN LopHocPhan lhp ON dk.ma_lhp = lhp.ma_lhp
    WHERE dk.ma_sinh_vien = @ma_sinh_vien
    AND lhp.hoc_ky = @hoc_ky
    AND lhp.nam_hoc = @nam_hoc;

    -- Kiểm tra điều kiện học bổng
    IF @diem_ren_luyen >= 90 AND @diem_trung_binh >= 9.0
    BEGIN
        INSERT INTO HocBong (ma_sinh_vien, hoc_ky, nam_hoc, loai_hoc_bong, gia_tri_hoc_bong, diem_ren_luyen, diem_trung_binh, ngay_cap, ghi_chu)
        VALUES (@ma_sinh_vien, @hoc_ky, @nam_hoc, N'Xuất sắc', 5000000, @diem_ren_luyen, @diem_trung_binh, GETDATE(), N'Học bổng Xuất sắc dựa trên điểm rèn luyện và học tập');
    END
    ELSE IF @diem_ren_luyen >= 80 AND @diem_trung_binh >= 8.0
    BEGIN
        INSERT INTO HocBong (ma_sinh_vien, hoc_ky, nam_hoc, loai_hoc_bong, gia_tri_hoc_bong, diem_ren_luyen, diem_trung_binh, ngay_cap, ghi_chu)
        VALUES (@ma_sinh_vien, @hoc_ky, @nam_hoc, N'Khá', 3000000, @diem_ren_luyen, @diem_trung_binh, GETDATE(), N'Học bổng Khá dựa trên điểm rèn luyện và học tập');
    END
END;
GO

-- Tạo chỉ mục
CREATE INDEX idx_ma_sinh_vien ON DangKyHocPhan(ma_sinh_vien);
CREATE INDEX idx_ma_lhp ON DangKyHocPhan(ma_lhp);
CREATE INDEX idx_ma_buoi ON DiemDanh(ma_buoi);
CREATE INDEX idx_ma_sinh_vien_diem_danh ON DiemDanh(ma_sinh_vien);
CREATE INDEX idx_ma_lhp_thai_do_hoc_tap ON ThaiDoHocTap(ma_lhp);
CREATE INDEX idx_ma_sinh_vien_thai_do_hoc_tap ON ThaiDoHocTap(ma_sinh_vien);
CREATE INDEX idx_ma_sinh_vien_vi_pham_ky_luat ON ViPhamKyLuat(ma_sinh_vien);
CREATE INDEX idx_ma_dang_ky_diem ON Diem(ma_dang_ky);
CREATE INDEX idx_ma_sinh_vien_diem_ren_luyen ON DiemRenLuyen(ma_sinh_vien);
CREATE INDEX idx_ma_lhp_lich_hoc ON LichHoc(ma_lhp);
CREATE INDEX idx_ma_lhp_tai_lieu_hoc_tap ON TaiLieuHocTap(ma_lhp);
CREATE INDEX idx_ma_sinh_vien_hoc_bong ON HocBong(ma_sinh_vien);
GO

-- View tính tỷ lệ chuyên cần
CREATE VIEW vw_TyLeDiemDanh AS
SELECT 
    dk.ma_sinh_vien,
    dk.ma_lhp,
    COUNT(CASE WHEN dd.trang_thai = N'Có mặt' THEN 1 END) * 100.0 / COUNT(dd.ma_diem_danh) AS ty_le_diem_danh
FROM DangKyHocPhan dk
LEFT JOIN BuoiHoc bh ON bh.ma_lhp = dk.ma_lhp
LEFT JOIN DiemDanh dd ON dd.ma_sinh_vien = dk.ma_sinh_vien AND dd.ma_buoi = bh.ma_buoi
WHERE bh.trang_thai = N'Đã diễn ra'
GROUP BY dk.ma_sinh_vien, dk.ma_lhp;
GO

-- Stored Procedure tính điểm rèn luyện
CREATE PROCEDURE sp_TinhDiemRenLuyen
    @ma_sinh_vien VARCHAR(10),
    @hoc_ky VARCHAR(1),
    @nam_hoc VARCHAR(9),
    @diem_thai_do INT
AS
BEGIN
    DECLARE @so_vi_pham INT;

    -- Tính số vi phạm trong năm học
    SET @so_vi_pham = (
        SELECT COUNT(*)
        FROM ViPhamKyLuat vpkl
        WHERE vpkl.ma_sinh_vien = @ma_sinh_vien
        AND YEAR(vpkl.ngay_vi_pham) = CAST(SUBSTRING(@nam_hoc, 1, 4) AS INT)
    );

    -- Tính điểm cuối cùng và xếp loại
    DECLARE @diem_cuoi_cung INT;
    SET @diem_cuoi_cung = COALESCE(@diem_thai_do, 80) - (@so_vi_pham * 5);

    -- Cập nhật điểm rèn luyện
    UPDATE DiemRenLuyen
    SET diem_cuoi_cung = @diem_cuoi_cung,
        xep_loai = CASE 
            WHEN @diem_cuoi_cung >= 90 THEN N'Xuất sắc'
            WHEN @diem_cuoi_cung >= 80 THEN N'Tốt'
            WHEN @diem_cuoi_cung >= 70 THEN N'Khá'
            WHEN @diem_cuoi_cung >= 60 THEN N'Trung bình'
            WHEN @diem_cuoi_cung >= 50 THEN N'Yếu'
            ELSE N'Kém'
        END
    WHERE ma_sinh_vien = @ma_sinh_vien
    AND hoc_ky = @hoc_ky
    AND nam_hoc = @nam_hoc;
END;
GO



-- Thêm dữ liệu cho bảng Khoa
INSERT INTO Khoa (ma_khoa, ten_khoa, truong_khoa, mo_ta)
VALUES 
('CNTT', N'Công nghệ thông tin', N'TS. Nguyễn Văn A', N'Khoa Công nghệ thông tin'),
('KTXD', N'Kỹ thuật xây dựng', N'TS. Lê Thị B', N'Khoa Kỹ thuật xây dựng'),
('KTCK', N'Kỹ thuật cơ khí', N'PGS.TS. Trần Văn C', N'Khoa Kỹ thuật cơ khí'),
('KTOTO', N'Kỹ thuật ô tô', N'TS. Phạm Thị D', N'Khoa Kỹ thuật ô tô'),
('QTKD', N'Quản trị kinh doanh', N'PGS.TS. Hoàng Văn E', N'Khoa Quản trị kinh doanh');
GO

-- Thêm dữ liệu cho bảng Giảng viên
INSERT INTO GiangVien (ma_giang_vien, ho_ten, gioi_tinh, email, ten_dang_nhap, mat_khau_bam, so_dien_thoai, ma_khoa, chuc_vu)
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

-- Thêm dữ liệu cho bảng Ngành học
INSERT INTO NganhHoc (ma_nganh, ten_nganh, ma_khoa, mo_ta)
VALUES 
('CNPM', N'Công nghệ phần mềm', 'CNTT', N'Ngành đào tạo về phát triển phần mềm'),
('KTPM', N'Kỹ thuật phần mềm', 'CNTT', N'Ngành đào tạo về kỹ thuật phần mềm'),
('XDDD', N'Xây dựng dân dụng', 'KTXD', N'Ngành đào tạo về xây dựng dân dụng và công nghiệp'),
('CNCK', N'Cơ khí chế tạo', 'KTCK', N'Ngành đào tạo về cơ khí chế tạo'),
('OTOKT', N'Kỹ thuật ô tô', 'KTOTO', N'Ngành đào tạo về kỹ thuật ô tô'),
('QTKD', N'Quản trị kinh doanh', 'QTKD', N'Ngành đào tạo về quản trị kinh doanh');
GO

-- Thêm dữ liệu cho bảng Lớp
INSERT INTO Lop (ma_lop, ten_lop, ma_khoa, ma_nganh, ma_gvcn, nam_bat_dau)
VALUES 
('CNPM01', N'Công nghệ phần mềm K45', 'CNTT', 'CNPM', 'GV001', 2023),
('KTPM01', N'Kỹ thuật phần mềm K45', 'CNTT', 'KTPM', 'GV006', 2023),
('XDDD01', N'Xây dựng dân dụng K45', 'KTXD', 'XDDD', 'GV002', 2023),
('CNCK01', N'Cơ khí chế tạo K45', 'KTCK', 'CNCK', 'GV003', 2023),
('OTOKT01', N'Kỹ thuật ô tô K45', 'KTOTO', 'OTOKT', 'GV004', 2023),
('QTKD01', N'Quản trị kinh doanh K45', 'QTKD', 'QTKD', 'GV005', 2023);
GO

-- Thêm dữ liệu cho bảng Sinh viên
INSERT INTO SinhVien (ma_sinh_vien, ho_ten, ngay_sinh, gioi_tinh, email, ten_dang_nhap, mat_khau_bam, so_dien_thoai, dia_chi, cccd, thong_tin_phu_huynh, ma_lop, ma_nganh, nam_nhap_hoc, trang_thai)
VALUES 
('SV001', N'Nguyễn Văn Hùng', '2003-05-10', N'Nam', 'SV001@st.utc2.edu.vn', 'nguyenvanhung', 'hashed_password_1', '0911111111', N'Hà Nội', '123456789012', N'Nguyễn Văn Ba', 'CNPM01', 'CNPM', 2023, N'Đang học'),
('SV002', N'Trần Thị Mai', '2003-07-15', N'Nữ', 'SV002@st.utc2.edu.vn', 'tranthimai', 'hashed_password_2', '0922222222', N'Hà Nội', '123456789013', N'Trần Văn An', 'CNPM01', 'CNPM', 2023, N'Đang học'),
('SV003', N'Lê Văn Nam', '2003-03-20', N'Nam', 'SV003@st.utc2.edu.vn', 'levannam', 'hashed_password_3', '0933333333', N'TP.HCM', '123456789014', N'Lê Thị Hoa', 'KTPM01', 'KTPM', 2023, N'Đang học'),
('SV004', N'Phạm Thị Lan', '2003-09-25', N'Nữ', 'SV004@st.utc2.edu.vn', 'phamthilan', 'hashed_password_4', '0944444444', N'Đà Nẵng', '123456789015', N'Phạm Văn Tâm', 'XDDD01', 'XDDD', 2023, N'Đang học'),
('SV005', N'Hoàng Văn Tùng', '2003-11-30', N'Nam', 'SV005@st.utc2.edu.vn', 'hoangvantung', 'hashed_password_5', '0955555555', N'Hà Nội', '123456789016', N'Hoàng Thị Mai', 'CNCK01', 'CNCK', 2023, N'Đang học'),
('SV006', N'Ngô Thị Hoa', '2003-01-12', N'Nữ', 'SV006@st.utc2.edu.vn', 'ngothihoa', 'hashed_password_6', '0966666666', N'Hải Phòng', '123456789017', N'Ngô Văn Long', 'OTOKT01', 'OTOKT', 2023, N'Đang học'),
('SV007', N'Vũ Văn Long', '2003-06-18', N'Nam', 'SV007@st.utc2.edu.vn', 'vuvanlong', 'hashed_password_7', '0977777777', N'Hà Nội', '123456789018', N'Vũ Thị Hương', 'QTKD01', 'QTKD', 2023, N'Đang học');
GO

-- Thêm dữ liệu cho bảng Môn học
INSERT INTO MonHoc (ma_mon_hoc, ten_mon_hoc, so_tin_chi, ma_khoa, mo_ta)
VALUES 
('TH01', N'Lập trình C++', 3, 'CNTT', N'Môn học về lập trình C++ cơ bản'),
('TH02', N'Cấu trúc dữ liệu', 3, 'CNTT', N'Môn học về cấu trúc dữ liệu và giải thuật'),
('XD01', N'Cơ sở kỹ thuật xây dựng', 3, 'KTXD', N'Môn học về kỹ thuật xây dựng cơ bản'),
('CK01', N'Cơ học chất rắn', 3, 'KTCK', N'Môn học về cơ học chất rắn'),
('OT01', N'Hệ thống động cơ ô tô', 3, 'KTOTO', N'Môn học về hệ thống động cơ ô tô'),
('QT01', N'Quản trị kinh doanh cơ bản', 3, 'QTKD', N'Môn học về quản trị kinh doanh cơ bản');
GO

-- Thêm dữ liệu cho bảng Lớp học phần
INSERT INTO LopHocPhan (ma_lhp, ma_mon_hoc, ma_giang_vien, hoc_ky, nam_hoc, si_so_toi_da, ngay_bat_dau_dang_ky, ngay_ket_thuc_dang_ky)
VALUES 
('TH01_2024_1', 'TH01', 'GV001', '1', '2024-2025', 50, '2024-08-01', '2024-08-15'),
('TH02_2024_1', 'TH02', 'GV006', '1', '2024-2025', 50, '2024-08-01', '2024-08-15'),
('XD01_2024_1', 'XD01', 'GV002', '1', '2024-2025', 50, '2024-08-01', '2024-08-15'),
('CK01_2024_1', 'CK01', 'GV003', '1', '2024-2025', 50, '2024-08-01', '2024-08-15'),
('OT01_2024_1', 'OT01', 'GV004', '1', '2024-2025', 50, '2024-08-01', '2024-08-15'),
('QT01_2024_1', 'QT01', 'GV005', '1', '2024-2025', 50, '2024-08-01', '2024-08-15');
GO

-- Thêm dữ liệu cho bảng Đăng ký học phần
INSERT INTO DangKyHocPhan (ma_sinh_vien, ma_lhp, ngay_dang_ky, trang_thai)
VALUES 
('SV001', 'TH01_2024_1', '2024-08-10', N'Đang học'),
('SV002', 'TH01_2024_1', '2024-08-10', N'Đang học'),
('SV003', 'TH02_2024_1', '2024-08-10', N'Đang học'),
('SV004', 'XD01_2024_1', '2024-08-10', N'Đang học'),
('SV005', 'CK01_2024_1', '2024-08-10', N'Đang học'),
('SV006', 'OT01_2024_1', '2024-08-10', N'Đang học'),
('SV007', 'QT01_2024_1', '2024-08-10', N'Đang học');
GO

-- Thêm dữ liệu cho bảng Buổi học
INSERT INTO BuoiHoc (ma_lhp, ngay_hoc, gio_bat_dau, gio_ket_thuc, phong_hoc, chu_de, trang_thai)
VALUES 
('TH01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'A101', N'Giới thiệu lập trình C++', N'Đã diễn ra'),
('TH02_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'A102', N'Mảng và con trỏ', N'Đã diễn ra'),
('XD01_2024_1', '2024-09-10', '13:00:00', '15:00:00', 'B201', N'Cơ sở kỹ thuật xây dựng', N'Đã diễn ra'),
('CK01_2024_1', '2024-09-10', '15:30:00', '17:30:00', 'C301', N'Cơ học chất rắn', N'Đã diễn ra'),
('OT01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'D401', N'Hệ thống động cơ ô tô', N'Đã diễn ra'),
('QT01_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'E501', N'Khái niệm quản trị', N'Đã diễn ra');
GO

-- Thêm dữ liệu cho bảng Điểm danh
INSERT INTO DiemDanh (ma_sinh_vien, ma_buoi, trang_thai, thoi_gian_ghi, ghi_chu)
VALUES 
('SV001', 1, N'Có mặt', '2024-09-10 07:10:00', NULL),
('SV002', 1, N'Có mặt', '2024-09-10 07:15:00', NULL),
('SV003', 2, N'Có mặt', '2024-09-10 09:40:00', NULL),
('SV004', 3, N'Có mặt', '2024-09-10 13:10:00', NULL),
('SV005', 4, N'Có mặt', '2024-09-10 15:40:00', NULL),
('SV006', 5, N'Có mặt', '2024-09-10 07:10:00', NULL),
('SV007', 6, N'Có mặt', '2024-09-10 09:40:00', NULL);
GO

-- Thêm dữ liệu cho bảng Thái độ học tập
INSERT INTO ThaiDoHocTap (ma_sinh_vien, ma_lhp, ty_le_tham_gia, muc_do_tap_trung, hoan_thanh_bai_tap, tham_gia_thao_luan, tinh_chu_dong, lam_viec_nhom, ton_trong, ma_nguoi_danh_gia, ngay_danh_gia)
VALUES 
('SV001', 'TH01_2024_1', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', 'GV001', '2024-09-15'),
('SV002', 'TH01_2024_1', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Xuất sắc', N'Xuất sắc', 'GV001', '2024-09-15'),
('SV003', 'TH02_2024_1', 80, N'Khá', 75, 7, N'Trung bình', N'Khá', N'Khá', 'GV006', '2024-09-15'),
('SV004', 'XD01_2024_1', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', 'GV002', '2024-09-15'),
('SV005', 'CK01_2024_1', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', 'GV003', '2024-09-15'),
('SV006', 'OT01_2024_1', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Xuất sắc', N'Xuất sắc', 'GV004', '2024-09-15'),
('SV007', 'QT01_2024_1', 80, N'Khá', 75, 7, N'Trung bình', N'Khá', N'Khá', 'GV005', '2024-09-15');
GO

-- Thêm dữ liệu cho bảng Vi phạm kỷ luật
INSERT INTO ViPhamKyLuat (ma_sinh_vien, ngay_vi_pham, loai_vi_pham, muc_do, bien_phap_xu_ly, ma_nguoi_bao_cao, ghi_chu)
VALUES 
('SV003', '2024-09-05', N'Đi muộn buổi học', N'Nhẹ', N'Nhắc nhở', 'GV006', N'Đi muộn 15 phút'),
('SV007', '2024-09-07', N'Sao chép bài tập', N'Trung bình', N'Khiển trách', 'GV005', N'Sao chép bài tập của bạn');
GO

-- Thêm dữ liệu cho bảng Điểm
INSERT INTO Diem (ma_dang_ky, diem_giua_ky, diem_cuoi_ky, diem_thuc_hanh, trang_thai)
VALUES 
(1, 8.5, 9.0, 8.0, N'Đã duyệt'),
(2, 9.0, 9.5, 8.5, N'Đã duyệt'),
(3, 7.5, 8.0, 7.0, N'Đã duyệt'),
(4, 8.0, 8.5, 7.5, N'Đã duyệt'),
(5, 8.5, 9.0, 8.0, N'Đã duyệt'),
(6, 9.0, 9.5, 8.5, N'Đã duyệt'),
(7, 7.5, 8.0, 7.0, N'Đã duyệt');
GO

-- Thêm dữ liệu cho bảng Điểm rèn luyện
INSERT INTO DiemRenLuyen (ma_sinh_vien, hoc_ky, nam_hoc, diem_tu_danh_gia, diem_lop, diem_khoa, diem_cuoi_cung, xep_loai, ma_nguoi_danh_gia, ngay_danh_gia)
VALUES 
('SV001', '1', '2024-2025', 90, 92, 91, 90, N'Xuất sắc', 'GV001', '2024-09-20'),
('SV002', '1', '2024-2025', 95, 94, 93, 95, N'Xuất sắc', 'GV001', '2024-09-20'),
('SV003', '1', '2024-2025', 80, 82, 81, 75, N'Khá', 'GV006', '2024-09-20'),
('SV004', '1', '2024-2025', 85, 87, 86, 85, N'Tốt', 'GV002', '2024-09-20'),
('SV005', '1', '2024-2025', 90, 92, 91, 90, N'Xuất sắc', 'GV003', '2024-09-20'),
('SV006', '1', '2024-2025', 95, 94, 93, 95, N'Xuất sắc', 'GV004', '2024-09-20'),
('SV007', '1', '2024-2025', 80, 82, 81, 75, N'Khá', 'GV005', '2024-09-20');
GO

-- Học bổng sẽ được tự động thêm bởi trigger trg_CapHocBong
-- Kiểm tra dữ liệu sau khi chạy trigger
PRINT N'Đã tạo database và thêm dữ liệu mẫu thành công!';
GO


-- Scholarships sẽ được tự động thêm bởi trigger trg_Assign_Scholarship
-- Dữ liệu mẫu sẽ được kiểm tra sau khi chạy trigger

PRINT N'Đã tạo database và thêm dữ liệu mẫu thành công!';