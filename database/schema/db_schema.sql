-- Tạo database
CREATE DATABASE [BTLSQL-ThaiDoHocTapSv];
GO
USE [BTLSQL-ThaiDoHocTapSv];
GO

-- Xóa các đối tượng cũ
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
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_DanhGiaSinhVien;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_DiemRenLuyen;
DROP TRIGGER IF EXISTS trg_KiemTra_ThoiGianDangKy;
DROP TRIGGER IF EXISTS trg_KiemTra_DiemDanh_DangKy;
DROP TRIGGER IF EXISTS trg_TinhDiemTong;
DROP TRIGGER IF EXISTS trg_CapHocBong;
DROP TRIGGER IF EXISTS trg_CapNhatSoSinhVien;
DROP TRIGGER IF EXISTS trg_CapNhatTyLeDiemDanh;

DROP VIEW IF EXISTS vw_TyLeDiemDanh;
DROP VIEW IF EXISTS vw_ThongTinHocBong;
DROP VIEW IF EXISTS vw_TongHopKetQuaHocTap;
DROP VIEW IF EXISTS vw_ThongKeDanhGiaSinhVien;
DROP PROCEDURE IF EXISTS sp_TinhDiemRenLuyen;
DROP PROCEDURE IF EXISTS sp_TaoBuoiHocTuLich;

DROP TABLE IF EXISTS DiemRenLuyen;
DROP TABLE IF EXISTS DanhGiaSinhVien;
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

PRINT N'Đã xóa tất cả các bảng, trigger, view và stored procedure trong database [BTLSQL-ThaiDoHocTapSv]';

-- Bảng Khoa
CREATE TABLE Khoa (
    ma_khoa VARCHAR(10) PRIMARY KEY,
    ten_khoa NVARCHAR(100) NOT NULL,
    truong_khoa NVARCHAR(100),
    mo_ta NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME()
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
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (ma_khoa) REFERENCES Khoa(ma_khoa)
);
GO

-- Bảng Ngành học
CREATE TABLE NganhHoc (
    ma_nganh VARCHAR(10) PRIMARY KEY,
    ten_nganh NVARCHAR(100) NOT NULL,
    ma_khoa VARCHAR(10) NOT NULL,
    mo_ta NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
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
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (ma_khoa) REFERENCES Khoa(ma_khoa),
    FOREIGN KEY (ma_nganh) REFERENCES NganhHoc(ma_nganh),
    FOREIGN KEY (ma_gvcn) REFERENCES GiangVien(ma_giang_vien),
    CONSTRAINT CHK_GVCN_Khoa CHECK (
        ma_gvcn IS NULL OR
        EXISTS (
            SELECT 1 FROM GiangVien 
            WHERE GiangVien.ma_giang_vien = Lop.ma_gvcn 
            AND GiangVien.ma_khoa = Lop.ma_khoa
        )
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
    ma_khoa VARCHAR(10) NOT NULL,
    nam_nhap_hoc INT NOT NULL CHECK (nam_nhap_hoc >= 2000 AND nam_nhap_hoc <= YEAR(GETDATE())),
    trang_thai NVARCHAR(20) NOT NULL DEFAULT N'Đang học' CHECK (trang_thai IN (N'Đang học', N'Bảo lưu', N'Thôi học', N'Tốt nghiệp')),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (ma_lop) REFERENCES Lop(ma_lop),
    FOREIGN KEY (ma_nganh) REFERENCES NganhHoc(ma_nganh),
    FOREIGN KEY (ma_khoa) REFERENCES Khoa(ma_khoa)
);
GO

-- Bảng Môn học
CREATE TABLE MonHoc (
    ma_mon_hoc VARCHAR(10) PRIMARY KEY,
    ten_mon_hoc NVARCHAR(100) NOT NULL,
    so_tin_chi INT NOT NULL CHECK (so_tin_chi BETWEEN 1 AND 10),
    ma_khoa VARCHAR(10) NOT NULL,
    mo_ta NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
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
    so_sinh_vien_hien_tai INT DEFAULT 0,
    ngay_bat_dau_dang_ky DATE,
    ngay_ket_thuc_dang_ky DATE,
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (ma_mon_hoc) REFERENCES MonHoc(ma_mon_hoc),
    FOREIGN KEY (ma_giang_vien) REFERENCES GiangVien(ma_giang_vien),
    CONSTRAINT CHK_ThoiGianHocKy CHECK (
        ngay_bat_dau_dang_ky >= 
            CASE hoc_ky 
                WHEN '1' THEN CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + '-08-01'
                WHEN '2' THEN CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + '-01-01'
                WHEN N'Hè' THEN CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + '-06-01'
            END
        AND ngay_ket_thuc_dang_ky <= 
            CASE hoc_ky 
                WHEN '1' THEN CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + '-12-31'
                WHEN '2' THEN CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + 1 + '-05-31'
                WHEN N'Hè' THEN CAST(SUBSTRING(nam_hoc, 1, 4) AS INT) + '-07-31'
            END
    )
);
GO

-- Bảng Đăng ký học phần
CREATE TABLE DangKyHocPhan (
    ma_dang_ky INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    ma_lhp VARCHAR(20) NOT NULL,
    ngay_dang_ky DATETIME NOT NULL CHECK (ngay_dang_ky <= SYSUTCDATETIME()),
    trang_thai NVARCHAR(20) NOT NULL CHECK (trang_thai IN (N'Đăng ký', N'Đang học', N'Hoàn thànhCTA', N'Đã hủy')),
    ty_le_diem_danh DECIMAL(5,2),
    ngay_cap_nhat_ty_le DATETIME,
    diem_giua_ky DECIMAL(4,2) CHECK (diem_giua_ky IS NULL OR diem_giua_ky BETWEEN 0 AND 10),
    diem_cuoi_ky DECIMAL(4,2) CHECK (diem_cuoi_ky IS NULL OR diem_cuoi_ky BETWEEN 0 AND 10),
    diem_thuc_hanh DECIMAL(4,2) CHECK (diem_thuc_hanh IS NULL OR diem_thuc_hanh BETWEEN 0 AND 10),
    diem_tong DECIMAL(4,2) CHECK (diem_tong IS NULL OR diem_tong BETWEEN 0 AND 10),
    diem_chu VARCHAR(2) CHECK (diem_chu IS NULL OR diem_chu IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F')),
    trang_thai_diem NVARCHAR(20) DEFAULT N'Chờ duyệt' CHECK (trang_thai_diem IS NULL OR trang_thai_diem IN (N'Chờ duyệt', N'Đã duyệt')),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
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
    thu NVARCHAR(20) CHECK (thu IN (N'Thứ 2', N'Thứ 3', N'Thứ 4', N'Thứ 5', N'Thứ 6', N'Thứ 7', N'Chủ nhật')),
    tiet_bat_dau INT CHECK (tiet_bat_dau BETWEEN 1 AND 12),
    tiet_ket_thuc INT CHECK (tiet_ket_thuc BETWEEN 1 AND 12),
    chu_de NVARCHAR(200),
    trang_thai NVARCHAR(20) NOT NULL DEFAULT N'Chưa diễn ra' CHECK (trang_thai IN (N'Đã diễn ra', N'Chưa diễn ra', N'Hủy')),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    CONSTRAINT CHK_ThoiGianBuoiHoc CHECK (gio_ket_thuc > gio_bat_dau),
    CONSTRAINT CHK_TietHoc CHECK (tiet_ket_thuc >= tiet_bat_dau)
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
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_SinhVienBuoiHoc UNIQUE (ma_sinh_vien, ma_buoi),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_buoi) REFERENCES BuoiHoc(ma_buoi)
);
GO

-- Bảng Đánh giá sinh viên
CREATE TABLE DanhGiaSinhVien (
    ma_danh_gia INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    loai_danh_gia NVARCHAR(20) NOT NULL CHECK (loai_danh_gia IN (N'Thái độ học tập', N'Vi phạm kỷ luật')),
    ma_lhp VARCHAR(20),
    ngay_danh_gia DATETIME NOT NULL CHECK (ngay_danh_gia <= SYSUTCDATETIME()),
    ma_nguoi_danh_gia VARCHAR(10) NOT NULL,
    ty_le_tham_gia DECIMAL(5,2) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (ty_le_tham_gia IS NULL OR ty_le_tham_gia BETWEEN 0 AND 100)) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    muc_do_tap_trung NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (muc_do_tap_trung IS NULL OR muc_do_tap_trung IN (N'Kém', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    hoan_thanh_bai_tap DECIMAL(5,2) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (hoan_thanh_bai_tap IS NULL OR hoan_thanh_bai_tap BETWEEN 0 AND 100)) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    tham_gia_thao_luan INT CHECK ((loai_danh_gia = N'Thái độ học tập' AND (tham_gia_thao_luan IS NULL OR tham_gia_thao_luan BETWEEN 0 AND 10)) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    tinh_chu_dong NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (tinh_chu_dong IS NULL OR tinh_chu_dong IN (N'Thụ động', N'Trung bình', N'Chủ động'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    lam_viec_nhom NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (lam_viec_nhom IS NULL OR lam_viec_nhom IN (N'Kém', N'Trung bình', N'Khá', N'Tốt'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    ton_trong NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (ton_trong IS NULL OR ton_trong IN (N'Kém', N'Trung bình', N'Khá', N'Tốt'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    loai_vi_pham NVARCHAR(100) CHECK (loai_danh_gia = N'Vi phạm kỷ luật' OR loai_vi_pham IS NULL),
    muc_do_vi_pham NVARCHAR(20) CHECK ((loai_danh_gia = N'Vi phạm kỷ luật' AND muc_do_vi_pham IN (N'Nhẹ', N'Trung bình', N'Nghiêm trọng', N'Rất nghiêm trọng')) OR loai_danh_gia = N'Thái độ học tập'),
    bien_phap_xu_ly NVARCHAR(200) CHECK (loai_danh_gia = N'Vi phạm kỷ luật' OR bien_phap_xu_ly IS NULL),
    ghi_chu NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    FOREIGN KEY (ma_nguoi_danh_gia) REFERENCES GiangVien(ma_giang_vien),
    CONSTRAINT CHK_SinhVien_DaDangKy CHECK (
        loai_danh_gia = N'Vi phạm kỷ luật' OR
        ma_lhp IS NULL OR
        EXISTS (
            SELECT 1 FROM DangKyHocPhan
            WHERE DangKyHocPhan.ma_sinh_vien = DanhGiaSinhVien.ma_sinh_vien
            AND DangKyHocPhan.ma_lhp = DanhGiaSinhVien.ma_lhp
        )
    ),
    CONSTRAINT CHK_DanhGia_SauDangKy CHECK (
        loai_danh_gia = N'Vi phạm kỷ luật' OR
        ma_lhp IS NULL OR
        ngay_danh_gia >= (
            SELECT MIN(ngay_dang_ky)
            FROM DangKyHocPhan
            WHERE DangKyHocPhan.ma_lhp = DanhGiaSinhVien.ma_lhp
            AND DangKyHocPhan.ma_sinh_vien = DanhGiaSinhVien.ma_sinh_vien
        )
    )
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
    co_hoc_bong BIT DEFAULT 0,
    loai_hoc_bong NVARCHAR(50) CHECK (loai_hoc_bong IS NULL OR loai_hoc_bong IN (N'Xuất sắc', N'Khá')),
    gia_tri_hoc_bong DECIMAL(10,2) CHECK (gia_tri_hoc_bong IS NULL OR gia_tri_hoc_bong >= 0),
    diem_trung_binh DECIMAL(4,2) CHECK (diem_trung_binh IS NULL OR diem_trung_binh BETWEEN 0 AND 10),
    ngay_cap_hoc_bong DATE,
    ghi_chu_hoc_bong NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT SYSUTCDATETIME(),
    ngay_cap_nhat DATETIME DEFAULT SYSUTCDATETIME(),
    CONSTRAINT UQ_SinhVienHocKyNamHoc UNIQUE (ma_sinh_vien, hoc_ky, nam_hoc),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_nguoi_danh_gia) REFERENCES GiangVien(ma_giang_vien)
);
GO

-- Tạo chỉ số để cải thiện hiệu suất
CREATE INDEX IX_DangKyHocPhan_ma_sinh_vien ON DangKyHocPhan(ma_sinh_vien);
CREATE INDEX IX_DangKyHocPhan_ma_lhp ON DangKyHocPhan(ma_lhp);
CREATE INDEX IX_DiemDanh_ma_sinh_vien ON DiemDanh(ma_sinh_vien);
CREATE INDEX IX_DiemDanh_ma_buoi ON DiemDanh(ma_buoi);
CREATE INDEX IX_DanhGiaSinhVien_ma_sinh_vien ON DanhGiaSinhVien(ma_sinh_vien);
GO

-- Trigger cập nhật thời gian Khoa
CREATE TRIGGER trg_CapNhat_ThoiGian_Khoa
ON Khoa
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE Khoa
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM Khoa k
    INNER JOIN inserted i ON k.ma_khoa = i.ma_khoa;
END;
GO

-- Trigger cập nhật thời gian Giảng viên
CREATE TRIGGER trg_CapNhat_ThoiGian_GiangVien
ON GiangVien
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE GiangVien
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM GiangVien gv
    INNER JOIN inserted i ON gv.ma_giang_vien = i.ma_giang_vien;
END;
GO

-- Trigger cập nhật thời gian Ngành học
CREATE TRIGGER trg_CapNhat_ThoiGian_NganhHoc
ON NganhHoc
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE NganhHoc
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM NganhHoc nh
    INNER JOIN inserted i ON nh.ma_nganh = i.ma_nganh;
END;
GO

-- Trigger cập nhật thời gian Lớp
CREATE TRIGGER trg_CapNhat_ThoiGian_Lop
ON Lop
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE Lop
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM Lop l
    INNER JOIN inserted i ON l.ma_lop = i.ma_lop;
END;
GO

-- Trigger cập nhật thời gian Sinh viên
CREATE TRIGGER trg_CapNhat_ThoiGian_SinhVien
ON SinhVien
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE SinhVien
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM SinhVien s
    INNER JOIN inserted i ON s.ma_sinh_vien = i.ma_sinh_vien;
END;
GO

-- Trigger cập nhật thời gian Môn học
CREATE TRIGGER trg_CapNhat_ThoiGian_MonHoc
ON MonHoc
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE MonHoc
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM MonHoc mh
    INNER JOIN inserted i ON mh.ma_mon_hoc = i.ma_mon_hoc;
END;
GO

-- Trigger cập nhật thời gian Lớp học phần
CREATE TRIGGER trg_CapNhat_ThoiGian_LopHocPhan
ON LopHocPhan
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE LopHocPhan
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM LopHocPhan lhp
    INNER JOIN inserted i ON lhp.ma_lhp = i.ma_lhp;
END;
GO

-- Trigger cập nhật thời gian Đăng ký học phần
CREATE TRIGGER trg_CapNhat_ThoiGian_DangKyHocPhan
ON DangKyHocPhan
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DangKyHocPhan
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM DangKyHocPhan dkhp
    INNER JOIN inserted i ON dkhp.ma_dang_ky = i.ma_dang_ky;
END;
GO

-- Trigger cập nhật thời gian Buổi học
CREATE TRIGGER trg_CapNhat_ThoiGian_BuoiHoc
ON BuoiHoc
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE BuoiHoc
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM BuoiHoc bh
    INNER JOIN inserted i ON bh.ma_buoi = i.ma_buoi;
END;
GO

-- Trigger cập nhật thời gian Điểm danh
CREATE TRIGGER trg_CapNhat_ThoiGian_DiemDanh
ON DiemDanh
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DiemDanh
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM DiemDanh dd
    INNER JOIN inserted i ON dd.ma_diem_danh = i.ma_diem_danh;
END;
GO

-- Trigger cập nhật thời gian Đánh giá sinh viên
CREATE TRIGGER trg_CapNhat_ThoiGian_DanhGiaSinhVien
ON DanhGiaSinhVien
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DanhGiaSinhVien
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM DanhGiaSinhVien dgsv
    INNER JOIN inserted i ON dgsv.ma_danh_gia = i.ma_danh_gia;
END;
GO

-- Trigger cập nhật thời gian Điểm rèn luyện
CREATE TRIGGER trg_CapNhat_ThoiGian_DiemRenLuyen
ON DiemRenLuyen
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DiemRenLuyen
    SET ngay_cap_nhat = SYSUTCDATETIME()
    FROM DiemRenLuyen drl
    INNER JOIN inserted i ON drl.ma_diem_ren_luyen = i.ma_diem_ren_luyen;
END;
GO

-- Trigger kiểm tra số sinh viên tối đa
CREATE TRIGGER trg_KiemTra_SoSinhVienToiDa
ON DangKyHocPhan
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @ma_lhp VARCHAR(20), @si_so_toi_da INT, @so_sinh_vien_hien_tai INT;

    SELECT @ma_lhp = ma_lhp FROM inserted;

    SELECT @si_so_toi_da = si_so_toi_da, @so_sinh_vien_hien_tai = so_sinh_vien_hien_tai
    FROM LopHocPhan
    WHERE ma_lhp = @ma_lhp;

    IF (SELECT COUNT(*) FROM DangKyHocPhan WHERE ma_lhp = @ma_lhp AND trang_thai != N'Đã hủy') > @si_so_toi_da
    BEGIN
        RAISERROR (N'Số sinh viên đăng ký vượt quá sĩ số tối đa của lớp học phần.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    UPDATE LopHocPhan
    SET so_sinh_vien_hien_tai = (SELECT COUNT(*) FROM DangKyHocPhan WHERE ma_lhp = @ma_lhp AND trang_thai != N'Đã hủy')
    WHERE ma_lhp = @ma_lhp;
END;
GO

-- Trigger kiểm tra ngày điểm danh
CREATE TRIGGER trg_KiemTra_NgayDiemDanh
ON DiemDanh
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BuoiHoc bh ON i.ma_buoi = bh.ma_buoi
        WHERE i.thoi_gian_ghi < CAST(bh.ngay_hoc AS DATETIME)
    )
    BEGIN
        RAISERROR (N'Thời gian điểm danh không được sớm hơn ngày học.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger kiểm tra trạng thái sinh viên
CREATE TRIGGER trg_KiemTra_TrangThaiSinhVien
ON DangKyHocPhan
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SinhVien sv ON i.ma_sinh_vien = sv.ma_sinh_vien
        WHERE sv.trang_thai != N'Đang học'
    )
    BEGIN
        RAISERROR (N'Chỉ sinh viên có trạng thái "Đang học" mới được đăng ký học phần.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger kiểm tra thời gian đăng ký
CREATE TRIGGER trg_KiemTra_ThoiGianDangKy
ON DangKyHocPhan
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN LopHocPhan lhp ON i.ma_lhp = lhp.ma_lhp
        WHERE i.ngay_dang_ky < lhp.ngay_bat_dau_dang_ky OR i.ngay_dang_ky > lhp.ngay_ket_thuc_dang_ky
    )
    BEGIN
        RAISERROR (N'Ngày đăng ký không nằm trong khoảng thời gian cho phép.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger kiểm tra điểm danh và đăng ký
CREATE TRIGGER trg_KiemTra_DiemDanh_DangKy
ON DiemDanh
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BuoiHoc bh ON i.ma_buoi = bh.ma_buoi
        WHERE NOT EXISTS (
            SELECT 1
            FROM DangKyHocPhan dkhp
            WHERE dkhp.ma_sinh_vien = i.ma_sinh_vien
            AND dkhp.ma_lhp = bh.ma_lhp
            AND dkhp.trang_thai != N'Đã hủy'
        )
    )
    BEGIN
        RAISERROR (N'Sinh viên chưa đăng ký học phần này nên không thể điểm danh.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Trigger tính điểm tổng
CREATE TRIGGER trg_TinhDiemTong
ON DangKyHocPhan
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DangKyHocPhan
    SET 
        diem_tong = (
            CASE 
                WHEN diem_giua_ky IS NOT NULL AND diem_cuoi_ky IS NOT NULL AND diem_thuc_hanh IS NOT NULL
                THEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2)
                ELSE NULL
            END
        ),
        diem_chu = (
            CASE 
                WHEN diem_giua_ky IS NOT NULL AND diem_cuoi_ky IS NOT NULL AND diem_thuc_hanh IS NOT NULL
                THEN 
                    CASE 
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 9.0 THEN 'A+'
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 8.5 THEN 'A'
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 8.0 THEN 'B+'
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 7.0 THEN 'B'
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 6.5 THEN 'C+'
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 5.5 THEN 'C'
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 5.0 THEN 'D+'
                        WHEN ROUND((diem_giua_ky * 0.3 + diem_thuc_hanh * 0.2 + diem_cuoi_ky * 0.5), 2) >= 4.0 THEN 'D'
                        ELSE 'F'
                    END
                ELSE NULL
            END
        )
    FROM DangKyHocPhan dkhp
    INNER JOIN inserted i ON dkhp.ma_dang_ky = i.ma_dang_ky;
END;
GO

-- Trigger cập nhật tỷ lệ điểm danh
CREATE TRIGGER trg_CapNhatTyLeDiemDanh
ON DiemDanh
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE DangKyHocPhan
    SET 
        ty_le_diem_danh = (
            SELECT 
                CASE 
                    WHEN COUNT(*) = 0 THEN 0
                    ELSE ROUND(
                        (SUM(CASE WHEN dd.trang_thai IN (N'Có mặt', N'Đi muộn') THEN 1 ELSE 0 END) * 100.0) / 
                        COUNT(*), 
                        2
                    )
                END
            FROM DiemDanh dd
            JOIN BuoiHoc bh ON dd.ma_buoi = bh.ma_buoi
            WHERE bh.ma_lhp = DangKyHocPhan.ma_lhp
            AND dd.ma_sinh_vien = DangKyHocPhan.ma_sinh_vien
        ),
        ngay_cap_nhat_ty_le = SYSUTCDATETIME()
    FROM DangKyHocPhan dkhp
    WHERE EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BuoiHoc bh ON i.ma_buoi = bh.ma_buoi
        WHERE bh.ma_lhp = dkhp.ma_lhp
        AND i.ma_sinh_vien = dkhp.ma_sinh_vien
    )
    OR EXISTS (
        SELECT 1
        FROM deleted d
        JOIN BuoiHoc bh ON d.ma_buoi = bh.ma_buoi
        WHERE bh.ma_lhp = dkhp.ma_lhp
        AND d.ma_sinh_vien = dkhp.ma_sinh_vien
    );
END;
GO

-- Trigger cấp học bổng
CREATE TRIGGER trg_CapHocBong
ON DiemRenLuyen
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DiemRenLuyen
    SET 
        co_hoc_bong = 
            CASE 
                WHEN diem_trung_binh >= 9.0 AND diem_cuoi_cung >= 90 THEN 1
                WHEN diem_trung_binh >= 8.0 AND diem_cuoi_cung >= 80 THEN 1
                ELSE 0
            END,
        loai_hoc_bong = 
            CASE 
                WHEN diem_trung_binh >= 9.0 AND diem_cuoi_cung >= 90 THEN N'Xuất sắc'
                WHEN diem_trung_binh >= 8.0 AND diem_cuoi_cung >= 80 THEN N'Khá'
                ELSE NULL
            END,
        gia_tri_hoc_bong = 
            CASE 
                WHEN diem_trung_binh >= 9.0 AND diem_cuoi_cung >= 90 THEN 5000000
                WHEN diem_trung_binh >= 8.0 AND diem_cuoi_cung >= 80 THEN 3000000
                ELSE NULL
            END,
        ngay_cap_hoc_bong = 
            CASE 
                WHEN diem_trung_binh >= 9.0 AND diem_cuoi_cung >= 90 THEN GETDATE()
                WHEN diem_trung_binh >= 8.0 AND diem_cuoi_cung >= 80 THEN GETDATE()
                ELSE NULL
            END,
        ghi_chu_hoc_bong = 
            CASE 
                WHEN diem_trung_binh >= 9.0 AND diem_cuoi_cung >= 90 THEN N'Học bổng xuất sắc'
                WHEN diem_trung_binh >= 8.0 AND diem_cuoi_cung >= 80 THEN N'Học bổng khá'
                ELSE NULL
            END
    FROM DiemRenLuyen drl
    INNER JOIN inserted i ON drl.ma_diem_ren_luyen = i.ma_diem_ren_luyen;
END;
GO

-- Trigger kiểm tra đánh giá kỳ hiện tại
CREATE TRIGGER trg_KiemTra_DanhGiaKyHienTai
ON DanhGiaSinhVien
FOR INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN LopHocPhan lhp ON i.ma_lhp = lhp.ma_lhp
        WHERE i.ngay_danh_gia < (
            CASE lhp.hoc_ky
                WHEN '1' THEN CAST(SUBSTRING(lhp.nam_hoc, 1, 4) AS INT) + '-08-01'
                WHEN '2' THEN CAST(SUBSTRING(lhp.nam_hoc, 1, 4) AS INT) + '-01-01'
                WHEN N'Hè' THEN CAST(SUBSTRING(lhp.nam_hoc, 1, 4) AS INT) + '-06-01'
            END
        )
        OR i.ngay_danh_gia > (
            CASE lhp.hoc_ky
                WHEN '1' THEN CAST(SUBSTRING(lhp.nam_hoc, 1, 4) AS INT) + '-12-31'
                WHEN '2' THEN CAST(SUBSTRING(lhp.nam_hoc, 1, 4) AS INT) + 1 + '-05-31'
                WHEN N'Hè' THEN CAST(SUBSTRING(lhp.nam_hoc, 1, 4) AS INT) + '-07-31'
            END
        )
    )
    BEGIN
        RAISERROR (N'Đánh giá phải được thực hiện trong khoảng thời gian của học kỳ.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Stored Procedure để tạo buổi học từ lịch
CREATE PROCEDURE sp_TaoBuoiHocTuLich
    @ma_lhp VARCHAR(20),
    @thu NVARCHAR(20),
    @tiet_bat_dau INT,
    @tiet_ket_thuc INT,
    @phong_hoc VARCHAR(20),
    @ngay_bat_dau DATE,
    @ngay_ket_thuc DATE
AS
BEGIN
    DECLARE @current_date DATE = @ngay_bat_dau;
    DECLARE @gio_bat_dau TIME;
    DECLARE @gio_ket_thuc TIME;

    -- Gán giờ bắt đầu và kết thúc dựa trên tiết học
    SET @gio_bat_dau = CASE 
        WHEN @tiet_bat_dau = 1 THEN '07:00:00'
        WHEN @tiet_bat_dau = 4 THEN '09:30:00'
        WHEN @tiet_bat_dau = 7 THEN '12:30:00'
        WHEN @tiet_bat_dau = 10 THEN '15:00:00'
        ELSE '07:00:00'
    END;

    SET @gio_ket_thuc = CASE 
        WHEN @tiet_ket_thuc = 3 THEN '09:15:00'
        WHEN @tiet_ket_thuc = 6 THEN '11:45:00'
        WHEN @tiet_ket_thuc = 9 THEN '14:45:00'
        WHEN @tiet_ket_thuc = 12 THEN '17:15:00'
        ELSE '09:15:00'
    END;

    WHILE @current_date <= @ngay_ket_thuc
    BEGIN
        IF DATENAME(WEEKDAY, @current_date) = 
            CASE @thu
                WHEN N'Thứ 2' THEN 'Monday'
                WHEN N'Thứ 3' THEN 'Tuesday'
                WHEN N'Thứ 4' THEN 'Wednesday'
                WHEN N'Thứ 5' THEN 'Thursday'
                WHEN N'Thứ 6' THEN 'Friday'
                WHEN N'Thứ 7' THEN 'Saturday'
                WHEN N'Chủ nhật' THEN 'Sunday'
            END
        BEGIN
            INSERT INTO BuoiHoc (
                ma_lhp, ngay_hoc, gio_bat_dau, gio_ket_thuc, phong_hoc, 
                thu, tiet_bat_dau, tiet_ket_thuc, trang_thai
            )
            VALUES (
                @ma_lhp, @current_date, @gio_bat_dau, @gio_ket_thuc, @phong_hoc,
                @thu, @tiet_bat_dau, @tiet_ket_thuc, N'Chưa diễn ra'
            );
        END
        SET @current_date = DATEADD(DAY, 1, @current_date);
    END;
END;
GO

-- Chèn dữ liệu
-- 1. Khoa
INSERT INTO Khoa (ma_khoa, ten_khoa, truong_khoa, mo_ta)
VALUES 
    ('CNTT', N'Công nghệ Thông tin', N'Nguyễn Văn An', N'Khoa đào tạo về công nghệ thông tin và phần mềm'),
    ('KT', N'Kinh tế', N'Trần Thị Bình', N'Khoa đào tạo về kinh tế và quản trị kinh doanh');
GO

-- 2. GiangVien
INSERT INTO GiangVien (ma_giang_vien, ho_ten, gioi_tinh, email, ten_dang_nhap, mat_khau_bam, so_dien_thoai, ma_khoa, chuc_vu)
VALUES 
    ('GV001', N'Nguyễn Văn An', N'Nam', 'nvanan@utc2.edu.vn', 'nvanan', 'hashed_password_1', '0901234567', 'CNTT', N'Trưởng khoa'),
    ('GV002', N'Trần Thị Mai', N'Nữ', 'ttmai@utc2.edu.vn', 'ttmai', 'hashed_password_2', '0912345678', 'CNTT', N'Giảng viên'),
    ('GV003', N'Lê Văn Hùng', N'Nam', 'lvhung@utc2.edu.vn', 'lvhung', 'hashed_password_3', '0923456789', 'KT', N'Giảng viên'),
    ('GV004', N'Phạm Thị Lan', N'Nữ', 'ptlan@utc2.edu.vn', 'ptlan', 'hashed_password_4', '0934567890', 'KT', N'Phó khoa');
GO

-- 3. NganhHoc
INSERT INTO NganhHoc (ma_nganh, ten_nganh, ma_khoa, mo_ta)
VALUES 
    ('CNTT01', N'Công nghệ Thông tin', 'CNTT', N'Ngành đào tạo về lập trình và hệ thống thông tin'),
    ('KTPM01', N'Kỹ thuật Phần mềm', 'CNTT', N'Ngành đào tạo về phát triển phần mềm'),
    ('QTKD01', N'Quản trị Kinh doanh', 'KT', N'Ngành đào tạo về quản lý và kinh doanh');
GO

-- 4. Lop
INSERT INTO Lop (ma_lop, ten_lop, ma_khoa, ma_nganh, ma_gvcn, nam_bat_dau)
VALUES 
    ('L001', N'K64-CNTT', 'CNTT', 'CNTT01', 'GV001', 2023),
    ('L002', N'K64-KTPM', 'CNTT', 'KTPM01', 'GV002', 2023),
    ('L003', N'K64-QTKD', 'KT', 'QTKD01', 'GV003', 2023);
GO

-- 5. SinhVien
INSERT INTO SinhVien (ma_sinh_vien, ho_ten, ngay_sinh, gioi_tinh, email, ten_dang_nhap, mat_khau_bam, so_dien_thoai, dia_chi, cccd, thong_tin_phu_huynh, ma_lop, ma_nganh, ma_khoa, nam_nhap_hoc, trang_thai)
VALUES 
    ('SV001', N'Trần Văn Bình', '2003-05-20', N'Nam', 'sv001@st.utc2.edu.vn', 'sv001', 'hashed_password_5', '0945678901', N'Hà Nội', '123456789012', N'Phụ huynh: Trần Văn Hùng', 'L001', 'CNTT01', 'CNTT', 2023, N'Đang học'),
    ('SV002', N'Nguyễn Thị Hoa', '2003-07-15', N'Nữ', 'sv002@st.utc2.edu.vn', 'sv002', 'hashed_password_6', '0956789012', N'Hải Phòng', '123456789013', N'Phụ huynh: Nguyễn Văn Nam', 'L001', 'CNTT01', 'CNTT', 2023, N'Đang học'),
    ('SV003', N'Lê Văn Cường', '2003-03-10', N'Nam', 'sv003@st.utc2.edu.vn', 'sv003', 'hashed_password_7', '0967890123', N'Đà Nẵng', '123456789014', N'Phụ huynh: Lê Thị Lan', 'L002', 'KTPM01', 'CNTT', 2023, N'Đang học'),
    ('SV004', N'Phạm Thị Duyên', '2003-09-25', N'Nữ', 'sv004@st.utc2.edu.vn', 'sv004', 'hashed_password_8', '0978901234', N'TP.HCM', '123456789015', N'Phụ huynh: Phạm Văn Tùng', 'L002', 'KTPM01', 'CNTT', 2023, N'Đang học'),
    ('SV005', N'Hoàng Văn Em', '2003-11-30', N'Nam', 'sv005@st.utc2.edu.vn', 'sv005', 'hashed_password_9', '0989012345', N'Cần Thơ', '123456789016', N'Phụ huynh: Hoàng Thị Mai', 'L003', 'QTKD01', 'KT', 2023, N'Đang học'),
    ('SV006', N'Vũ Thị Phượng', '2003-01-12', N'Nữ', 'sv006@st.utc2.edu.vn', 'sv006', 'hashed_password_10', '0990123456', N'Hà Nội', '123456789017', N'Phụ huynh: Vũ Văn Hòa', 'L003', 'QTKD01', 'KT', 2023, N'Đang học');
GO

-- 6. MonHoc
INSERT INTO MonHoc (ma_mon_hoc, ten_mon_hoc, so_tin_chi, ma_khoa, mo_ta)
VALUES 
    ('MH001', N'Lập trình C', 3, 'CNTT', N'Môn học về lập trình cơ bản với ngôn ngữ C'),
    ('MH002', N'Cơ sở dữ liệu', 3, 'CNTT', N'Môn học về quản lý và thiết kế cơ sở dữ liệu'),
    ('MH003', N'Kỹ thuật lập trình', 4, 'CNTT', N'Môn học về kỹ thuật lập trình nâng cao'),
    ('MH004', N'Quản trị kinh doanh', 3, 'KT', N'Môn học về các nguyên lý quản trị kinh doanh'),
    ('MH005', N'Marketing căn bản', 3, 'KT', N'Môn học về các khái niệm cơ bản của marketing');
GO

-- 7. LopHocPhan
INSERT INTO LopHocPhan (ma_lhp, ma_mon_hoc, ma_giang_vien, hoc_ky, nam_hoc, si_so_toi_da, ngay_bat_dau_dang_ky, ngay_ket_thuc_dang_ky)
VALUES 
    ('LHP001', 'MH001', 'GV001', '2', '2024-2025', 50, '2025-01-01', '2025-01-15'),
    ('LHP002', 'MH002', 'GV002', '2', '2024-2025', 40, '2025-01-01', '2025-01-15'),
    ('LHP003', 'MH004', 'GV003', '2', '2024-2025', 60, '2025-01-01', '2025-01-15'),
    ('LHP004', 'MH005', 'GV004', '2', '2024-2025', 50, '2025-01-01', '2025-01-15');
GO

-- 8. DangKyHocPhan
INSERT INTO DangKyHocPhan (ma_sinh_vien, ma_lhp, ngay_dang_ky, trang_thai, diem_giua_ky, diem_thuc_hanh, diem_cuoi_ky)
VALUES 
    ('SV001', 'LHP001', '2025-01-10', N'Đang học', 8.5, 9.0, 8.0),
    ('SV001', 'LHP002', '2025-01-11', N'Đang học', 7.5, 8.0, 7.0),
    ('SV002', 'LHP001', '2025-01-10', N'Đang học', 9.0, 8.5, 9.5),
    ('SV002', 'LHP002', '2025-01-12', N'Đang học', 8.0, 7.5, 8.5),
    ('SV003', 'LHP001', '2025-01-11', N'Đang học', 7.0, 7.5, 6.5),
    ('SV003', 'LHP002', '2025-01-10', N'Đang học', 6.5, 7.0, 6.0),
    ('SV004', 'LHP001', '2025-01-12', N'Đang học', 8.0, 8.5, 7.5),
    ('SV005', 'LHP003', '2025-01-10', N'Đang học', 9.0, 9.5, 8.5),
    ('SV005', 'LHP004', '2025-01-11', N'Đang học', 8.5, 8.0, 9.0),
    ('SV006', 'LHP003', '2025-01-12', N'Đang học', 7.5, 8.0, 7.0);
GO

-- 9. BuoiHoc
EXEC sp_TaoBuoiHocTuLich 
    @ma_lhp = 'LHP001',
    @thu = N'Thứ 2',
    @tiet_bat_dau = 1,
    @tiet_ket_thuc = 3,
    @phong_hoc = 'P101',
    @ngay_bat_dau = '2025-01-20',
    @ngay_ket_thuc = '2025-03-31';
GO

EXEC sp_TaoBuoiHocTuLich 
    @ma_lhp = 'LHP002',
    @thu = N'Thứ 4',
    @tiet_bat_dau = 4,
    @tiet_ket_thuc = 6,
    @phong_hoc = 'P102',
    @ngay_bat_dau = '2025-01-22',
    @ngay_ket_thuc = '2025-04-02';
GO

EXEC sp_TaoBuoiHocTuLich 
    @ma_lhp = 'LHP003',
    @thu = N'Thứ 3',
    @tiet_bat_dau = 7,
    @tiet_ket_thuc = 9,
    @phong_hoc = 'P201',
    @ngay_bat_dau = '2025-01-21',
    @ngay_ket_thuc = '2025-04-01';
GO

EXEC sp_TaoBuoiHocTuLich 
    @ma_lhp = 'LHP004',
    @thu = N'Thứ 5',
    @tiet_bat_dau = 1,
    @tiet_ket_thuc = 3,
    @phong_hoc = 'P202',
    @ngay_bat_dau = '2025-01-23',
    @ngay_ket_thuc = '2025-04-03';
GO

-- Update trạng thái buổi học đã diễn ra (trước ngày hiện tại 19/04/2025)
UPDATE BuoiHoc
SET trang_thai = N'Đã diễn ra'
WHERE ngay_hoc < '2025-04-19';
GO

-- 10. DiemDanh
INSERT INTO DiemDanh (ma_sinh_vien, ma_buoi, trang_thai, thoi_gian_ghi, ghi_chu)
VALUES 
    ('SV001', 1, N'Có mặt', '2025-01-20 07:30:00', NULL),
    ('SV002', 1, N'Có mặt', '2025-01-20 07:30:00', NULL),
    ('SV003', 1, N'Vắng mặt', '2025-01-20 07:30:00', N'Không có lý do'),
    ('SV004', 1, N'Đi muộn', '2025-01-20 07:45:00', N'Đến muộn 15 phút'),
    ('SV001', 5, N'Có mặt', '2025-02-17 07:30:00', NULL),
    ('SV002', 5, N'Có phép', '2025-02-17 07:30:00', N'Xin nghỉ ốm'),
    ('SV003', 5, N'Có mặt', '2025-02-17 07:30:00', NULL),
    ('SV004', 5, N'Có mặt', '2025-02-17 07:30:00', NULL),
    ('SV001', 9, N'Có mặt', '2025-03-17 07:30:00', NULL),
    ('SV002', 9, N'Có mặt', '2025-03-17 07:30:00', NULL),
    ('SV003', 9, N'Đi muộn', '2025-03-17 07:40:00', N'Đến muộn 10 phút'),
    ('SV004', 9, N'Có mặt', '2025-03-17 07:30:00', NULL),
    ('SV001', 13, N'Có mặt', '2025-01-22 09:30:00', NULL),
    ('SV002', 13, N'Có mặt', '2025-01-22 09:30:00', NULL),
    ('SV003', 13, N'Có mặt', '2025-01-22 09:30:00', NULL),
    ('SV001', 17, N'Vắng mặt', '2025-02-19 09:30:00', N'Không có lý do'),
    ('SV002', 17, N'Có mặt', '2025-02-19 09:30:00', NULL),
    ('SV003', 17, N'Có mặt', '2025-02-19 09:30:00', NULL),
    ('SV005', 21, N'Có mặt', '2025-01-21 12:30:00', NULL),
    ('SV006', 21, N'Có mặt', '2025-01-21 12:30:00', NULL),
    ('SV005', 25, N'Có mặt', '2025-02-18 12:30:00', NULL),
    ('SV006', 25, N'Đi muộn', '2025-02-18 12:40:00', N'Đến muộn 10 phút'),
    ('SV005', 29, N'Có mặt', '2025-01-23 07:00:00', NULL),
    ('SV006', 29, N'Có mặt', '2025-01-23 07:00:00', NULL),
    ('SV005', 33, N'Có phép', '2025-02-20 07:00:00', N'Xin nghỉ gia đình'),
    ('SV006', 33, N'Có mặt', '2025-02-20 07:00:00', NULL);
GO

-- 11. DanhGiaSinhVien
INSERT INTO DanhGiaSinhVien (ma_sinh_vien, loai_danh_gia, ma_lhp, ngay_danh_gia, ma_nguoi_danh_gia, ty_le_tham_gia, muc_do_tap_trung, hoan_thanh_bai_tap, tham_gia_thao_luan, tinh_chu_dong, lam_viec_nhom, ton_trong, loai_vi_pham, muc_do_vi_pham, bien_phap_xu_ly, ghi_chu)
VALUES 
    ('SV001', N'Thái độ học tập', 'LHP001', '2025-02-15 10:00:00', 'GV001', 90, N'Tốt', 85, 8, N'Chủ động', N'Khá', N'Tốt', NULL, NULL, NULL, N'Sinh viên tích cực tham gia học tập'),
    ('SV002', N'Thái độ học tập', 'LHP001', '2025-02-15 10:00:00', 'GV001', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', NULL, NULL, NULL, N'Sinh viên rất chăm chỉ'),
    ('SV003', N'Thái độ học tập', 'LHP001', '2025-02-15 10:00:00', 'GV001', 70, N'Trung bình', 60, 6, N'Thụ động', N'Kém', N'Trung bình', NULL, NULL, NULL, N'Cần cải thiện thái độ học tập'),
    ('SV004', N'Thái độ học tập', 'LHP001', '2025-02-15 10:00:00', 'GV001', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', NULL, NULL, NULL, N'Sinh viên ổn, cần chủ động hơn'),
    ('SV001', N'Thái độ học tập', 'LHP002', '2025-03-01 14:00:00', 'GV002', 80, N'Khá', 75, 7, N'Trung bình', N'Trung bình', N'Tốt', NULL, NULL, NULL, N'Sinh viên cần tập trung hơn trong giờ học'),
    ('SV002', N'Thái độ học tập', 'LHP002', '2025-03-01 14:00:00', 'GV002', 90, N'Tốt', 85, 8, N'Chủ động', N'Khá', N'Tốt', NULL, NULL, NULL, N'Sinh viên học tốt, tích cực thảo luận'),
    ('SV003', N'Thái độ học tập', 'LHP002', '2025-03-01 14:00:00', 'GV002', 65, N'Trung bình', 60, 5, N'Thụ động', N'Kém', N'Trung bình', NULL, NULL, NULL, N'Cần cải thiện thái độ và sự tham gia'),
    ('SV005', N'Thái độ học tập', 'LHP003', '2025-03-10 09:00:00', 'GV003', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', NULL, NULL, NULL, N'Sinh viên rất tích cực và chăm chỉ'),
    ('SV006', N'Thái độ học tập', 'LHP003', '2025-03-10 09:00:00', 'GV003', 80, N'Khá', 75, 7, N'Trung bình', N'Khá', N'Khá', NULL, NULL, NULL, N'Sinh viên cần tham gia thảo luận nhiều hơn'),
    ('SV005', N'Thái độ học tập', 'LHP004', '2025-03-15 11:00:00', 'GV004', 90, N'Tốt', 85, 8, N'Chủ động', N'Khá', N'Tốt', NULL, NULL, NULL, N'Sinh viên học tốt, hoàn thành bài tập đầy đủ'),
    ('SV006', N'Thái độ học tập', 'LHP004', '2025-03-15 11:00:00', 'GV004', 85, N'Khá', 80, 7, N'Trung bình', N'Khá', N'Khá', NULL, NULL, NULL, N'Sinh viên ổn, cần tập trung hơn'),
    ('SV003', N'Vi phạm kỷ luật', NULL, '2025-02-20 08:00:00', 'GV001', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Đi muộn nhiều lần', N'Trung bình', N'Cảnh cáo', N'Sinh viên cần cải thiện ý thức'),
    ('SV006', N'Vi phạm kỷ luật', NULL, '2025-03-05 09:00:00', 'GV003', NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'Sao chép bài tập', N'Nghiêm trọng', N'Khiển trách', N'Sinh viên vi phạm quy chế học tập');
GO