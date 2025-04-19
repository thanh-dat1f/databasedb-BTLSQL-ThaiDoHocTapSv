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
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_DanhGiaSinhVien;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_DiemRenLuyen;
DROP TRIGGER IF EXISTS trg_CapNhat_ThoiGian_TaiLieuHocTap;
DROP TRIGGER IF EXISTS trg_KiemTra_ThoiGianDangKy;
DROP TRIGGER IF EXISTS trg_KiemTra_DiemDanh_DangKy;
DROP TRIGGER IF EXISTS trg_TinhDiemTong;
DROP TRIGGER IF EXISTS trg_CapHocBong;
DROP TRIGGER IF EXISTS trg_CapNhatSoSinhVien;
DROP TRIGGER IF EXISTS trg_CapNhatTyLeDiemDanh;

-- Xóa các view và stored procedure trước
DROP VIEW IF EXISTS vw_TyLeDiemDanh;
DROP VIEW IF EXISTS vw_ThongTinHocBong;
DROP PROCEDURE IF EXISTS sp_TinhDiemRenLuyen;
DROP PROCEDURE IF EXISTS sp_TaoBuoiHocTuLich;

-- Xóa các bảng theo thứ tự
DROP TABLE IF EXISTS TaiLieuHocTap;
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
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
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
    so_sinh_vien_hien_tai INT DEFAULT 0,
    ngay_bat_dau_dang_ky DATE,
    ngay_ket_thuc_dang_ky DATE,
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
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

-- Bảng Đăng ký học phần (đã gộp với TyLeDiemDanh và Diem)
CREATE TABLE DangKyHocPhan (
    ma_dang_ky INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    ma_lhp VARCHAR(20) NOT NULL,
    ngay_dang_ky DATETIME NOT NULL CHECK (ngay_dang_ky <= GETDATE()),
    trang_thai NVARCHAR(20) NOT NULL CHECK (trang_thai IN (N'Đăng ký', N'Đang học', N'Hoàn thành', N'Đã hủy')),
    -- Các trường từ bảng TyLeDiemDanh
    ty_le_diem_danh DECIMAL(5,2),
    ngay_cap_nhat_ty_le DATETIME,
    -- Các trường từ bảng Diem
    diem_giua_ky DECIMAL(4,2) CHECK (diem_giua_ky IS NULL OR diem_giua_ky BETWEEN 0 AND 10),
    diem_cuoi_ky DECIMAL(4,2) CHECK (diem_cuoi_ky IS NULL OR diem_cuoi_ky BETWEEN 0 AND 10),
    diem_thuc_hanh DECIMAL(4,2) CHECK (diem_thuc_hanh IS NULL OR diem_thuc_hanh BETWEEN 0 AND 10),
    diem_tong DECIMAL(4,2) CHECK (diem_tong IS NULL OR diem_tong BETWEEN 0 AND 10),
    diem_chu VARCHAR(2) CHECK (diem_chu IS NULL OR diem_chu IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F')),
    trang_thai_diem NVARCHAR(20) DEFAULT N'Chờ duyệt' CHECK (trang_thai_diem IS NULL OR trang_thai_diem IN (N'Chờ duyệt', N'Đã duyệt')),
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
    thu NVARCHAR(20) CHECK (thu IN (N'Thứ 2', N'Thứ 3', N'Thứ 4', N'Thứ 5', N'Thứ 6', N'Thứ 7', N'Chủ nhật')),
    tiet_bat_dau INT CHECK (tiet_bat_dau BETWEEN 1 AND 12),
    tiet_ket_thuc INT CHECK (tiet_ket_thuc BETWEEN 1 AND 12),
    chu_de NVARCHAR(200),
    trang_thai NVARCHAR(20) NOT NULL DEFAULT N'Chưa diễn ra' CHECK (trang_thai IN (N'Đã diễn ra', N'Chưa diễn ra', N'Hủy')),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    CONSTRAINT CHK_ThoiGianBuoiHoc CHECK (gio_ket_thuc > gio_bat_dau),
    CONSTRAINT CHK_TietHoc CHECK (tiet_ket_thuc >= tiet_bat_dau)
);
GO

-- Bảng Điểm danh (giữ nguyên)
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

-- Bảng DanhGiaSinhVien (thay thế cho ThaiDoHocTap và ViPhamKyLuat)
CREATE TABLE DanhGiaSinhVien (
    ma_danh_gia INT IDENTITY(1,1) PRIMARY KEY,
    ma_sinh_vien VARCHAR(10) NOT NULL,
    loai_danh_gia NVARCHAR(20) NOT NULL CHECK (loai_danh_gia IN (N'Thái độ học tập', N'Vi phạm kỷ luật')),
    ma_lhp VARCHAR(20),
    ngay_danh_gia DATETIME NOT NULL CHECK (ngay_danh_gia <= GETDATE()),
    ma_nguoi_danh_gia VARCHAR(10) NOT NULL,
    
    -- Các trường cho thái độ học tập
    ty_le_tham_gia DECIMAL(5,2) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (ty_le_tham_gia IS NULL OR ty_le_tham_gia BETWEEN 0 AND 100)) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    muc_do_tap_trung NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (muc_do_tap_trung IS NULL OR muc_do_tap_trung IN (N'Kém', N'Trung bình', N'Khá', N'Tốt', N'Xuất sắc'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    hoan_thanh_bai_tap DECIMAL(5,2) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (hoan_thanh_bai_tap IS NULL OR hoan_thanh_bai_tap BETWEEN 0 AND 100)) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    tham_gia_thao_luan INT CHECK ((loai_danh_gia = N'Thái độ học tập' AND (tham_gia_thao_luan IS NULL OR tham_gia_thao_luan BETWEEN 0 AND 10)) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    tinh_chu_dong NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (tinh_chu_dong IS NULL OR tinh_chu_dong IN (N'Thụ động', N'Trung bình', N'Chủ động'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    lam_viec_nhom NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (lam_viec_nhom IS NULL OR lam_viec_nhom IN (N'Kém', N'Trung bình', N'Khá', N'Tốt'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    ton_trong NVARCHAR(20) CHECK ((loai_danh_gia = N'Thái độ học tập' AND (ton_trong IS NULL OR ton_trong IN (N'Kém', N'Trung bình', N'Khá', N'Tốt'))) OR loai_danh_gia = N'Vi phạm kỷ luật'),
    
    -- Các trường cho vi phạm kỷ luật
    loai_vi_pham NVARCHAR(100) CHECK (loai_danh_gia = N'Vi phạm kỷ luật' OR loai_vi_pham IS NULL),
    muc_do_vi_pham NVARCHAR(20) CHECK ((loai_danh_gia = N'Vi phạm kỷ luật' AND muc_do_vi_pham IN (N'Nhẹ', N'Trung bình', N'Nghiêm trọng', N'Rất nghiêm trọng')) OR loai_danh_gia = N'Thái độ học tập'),
    bien_phap_xu_ly NVARCHAR(200) CHECK (loai_danh_gia = N'Vi phạm kỷ luật' OR bien_phap_xu_ly IS NULL),
    
    ghi_chu NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_lhp) REFERENCES LopHocPhan(ma_lhp),
    FOREIGN KEY (ma_nguoi_danh_gia) REFERENCES GiangVien(ma_giang_vien),
    
    -- Ràng buộc kiểm tra sinh viên đã đăng ký học phần (chỉ áp dụng cho đánh giá thái độ)
    CONSTRAINT CHK_SinhVien_DaDangKy CHECK (
        loai_danh_gia = N'Vi phạm kỷ luật' OR
        ma_lhp IS NULL OR
        EXISTS (
            SELECT 1 FROM DangKyHocPhan
            WHERE DangKyHocPhan.ma_sinh_vien = DanhGiaSinhVien.ma_sinh_vien
            AND DangKyHocPhan.ma_lhp = DanhGiaSinhVien.ma_lhp
        )
    ),
    
    -- Ràng buộc kiểm tra đánh giá sau đăng ký (chỉ áp dụng cho đánh giá thái độ)
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

-- Bảng Điểm rèn luyện (đã gộp với HocBong)
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
    -- Các trường từ bảng HocBong
    co_hoc_bong BIT DEFAULT 0, -- 1 nếu có học bổng, 0 nếu không
    loai_hoc_bong NVARCHAR(50) CHECK (loai_hoc_bong IS NULL OR loai_hoc_bong IN (N'Xuất sắc', N'Khá')),
    gia_tri_hoc_bong DECIMAL(10,2) CHECK (gia_tri_hoc_bong IS NULL OR gia_tri_hoc_bong >= 0),
    diem_trung_binh DECIMAL(4,2) CHECK (diem_trung_binh IS NULL OR diem_trung_binh BETWEEN 0 AND 10),
    ngay_cap_hoc_bong DATE,
    ghi_chu_hoc_bong NVARCHAR(MAX),
    ngay_tao DATETIME DEFAULT GETDATE(),
    ngay_cap_nhat DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_SinhVienHocKyNamHoc UNIQUE (ma_sinh_vien, hoc_ky, nam_hoc),
    FOREIGN KEY (ma_sinh_vien) REFERENCES SinhVien(ma_sinh_vien),
    FOREIGN KEY (ma_nguoi_danh_gia) REFERENCES GiangVien(ma_giang_vien)
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
    FOREIGN KEY (ma_nguoi_tai_len) REFERENCES GiangVien(ma_giang_vien),
    CONSTRAINT CHK_DuongDan CHECK (duong_dan LIKE '%.pdf' OR duong_dan LIKE '%.docx' OR duong_dan LIKE '%.pptx')
);
GO

-- Trigger tự động cập nhật ngay_cap_nhat
CREATE TRIGGER trg_CapNhat_ThoiGian_MonHoc
ON MonHoc
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DiemDanh
    SET ngay_cap_nhat = GETDATE()
    FROM DiemDanh dd
    INNER JOIN inserted i ON dd.ma_diem_danh = i.ma_diem_danh;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_DanhGiaSinhVien
ON DanhGiaSinhVien
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DanhGiaSinhVien
    SET ngay_cap_nhat = GETDATE()
    FROM DanhGiaSinhVien tdht
    INNER JOIN inserted i ON tdht.ma_danh_gia = i.ma_danh_gia;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_DiemRenLuyen
ON DiemRenLuyen
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE DiemRenLuyen
    SET ngay_cap_nhat = GETDATE()
    FROM DiemRenLuyen drl
    INNER JOIN inserted i ON drl.ma_diem_ren_luyen = i.ma_diem_ren_luyen;
END;
GO

CREATE TRIGGER trg_CapNhat_ThoiGian_TaiLieuHocTap
ON TaiLieuHocTap
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE TaiLieuHocTap
    SET ngay_cap_nhat = GETDATE()
    FROM TaiLieuHocTap tl
    INNER JOIN inserted i ON tl.ma_tai_lieu = i.ma_tai_lieu;
END;
GO

-- Trigger kiểm tra số lượng sinh viên đăng ký
CREATE TRIGGER trg_CapNhatSoSinhVien
ON DangKyHocPhan
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE LopHocPhan
    SET so_sinh_vien_hien_tai = (
        SELECT COUNT(*)
        FROM DangKyHocPhan dk
        WHERE dk.ma_lhp = LopHocPhan.ma_lhp
        AND dk.trang_thai IN (N'Đăng ký', N'Đang học', N'Hoàn thành')
    )
    FROM LopHocPhan
    WHERE ma_lhp IN (SELECT ma_lhp FROM inserted UNION SELECT ma_lhp FROM deleted);

    IF EXISTS (
        SELECT 1
        FROM LopHocPhan
        WHERE so_sinh_vien_hien_tai > si_so_toi_da
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Số lượng sinh viên vượt quá sĩ số tối đa', 1;
    END
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
FOR INSERT, UPDATE
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
ON DanhGiaSinhVien
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        WHERE i.loai_danh_gia = N'Thái độ học tập'
        AND i.ma_lhp IS NOT NULL
        AND EXISTS (
            SELECT 1
            FROM DangKyHocPhan dk
            WHERE dk.ma_sinh_vien = i.ma_sinh_vien
            AND dk.ma_lhp = i.ma_lhp
            AND (i.ngay_danh_gia < dk.ngay_dang_ky OR i.ngay_danh_gia > GETDATE())
        )
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
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        JOIN LopHocPhan lhp ON i.ma_lhp = lhp.ma_lhp
        WHERE i.ngay_dang_ky < lhp.ngay_bat_dau_dang_ky 
           OR i.ngay_dang_ky > lhp.ngay_ket_thuc_dang_ky
           OR lhp.ngay_ket_thuc_dang_ky <= lhp.ngay_bat_dau_dang_ky
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50005, N'Ngày đăng ký không hợp lệ hoặc thời gian đăng ký của lớp học phần không hợp lý', 1;
    END
END;
GO

-- Trigger kiểm tra đăng ký trước điểm danh
CREATE TRIGGER trg_KiemTra_DiemDanh_DangKy
ON DiemDanh
FOR INSERT, UPDATE
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
ON DangKyHocPhan
FOR UPDATE
AS
BEGIN
    IF UPDATE(diem_giua_ky) OR UPDATE(diem_thuc_hanh) OR UPDATE(diem_cuoi_ky)
    BEGIN
        UPDATE DangKyHocPhan
        SET diem_tong = (
                COALESCE(diem_giua_ky, 0) * 0.3 + 
                COALESCE(diem_thuc_hanh, 0) * 0.2 + 
                COALESCE(diem_cuoi_ky, 0) * 0.5
            ),
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
            END,
            ngay_cap_nhat = GETDATE()
        FROM DangKyHocPhan d
        INNER JOIN inserted i ON d.ma_dang_ky = i.ma_dang_ky
        WHERE i.diem_giua_ky IS NOT NULL 
          AND i.diem_thuc_hanh IS NOT NULL 
          AND i.diem_cuoi_ky IS NOT NULL;
    END
END;
GO

-- Trigger cập nhật tỷ lệ điểm danh
CREATE TRIGGER trg_CapNhatTyLeDiemDanh
ON DiemDanh
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    MERGE INTO DangKyHocPhan AS target
    USING (
        SELECT 
            dk.ma_dang_ky,
            COUNT(CASE WHEN dd.trang_thai = N'Có mặt' THEN 1 END) * 100.0 / NULLIF(COUNT(dd.ma_diem_danh), 0) AS ty_le
        FROM DangKyHocPhan dk
        LEFT JOIN BuoiHoc bh ON bh.ma_lhp = dk.ma_lhp
        LEFT JOIN DiemDanh dd ON dd.ma_sinh_vien = dk.ma_sinh_vien AND dd.ma_buoi = bh.ma_buoi
        WHERE bh.trang_thai = N'Đã diễn ra'
          AND dk.ma_lhp IN (
              SELECT bh.ma_lhp 
              FROM BuoiHoc bh 
              JOIN inserted i ON bh.ma_buoi = i.ma_buoi
              UNION
              SELECT bh.ma_lhp 
              FROM BuoiHoc bh 
              JOIN deleted d ON bh.ma_buoi = d.ma_buoi
          )
        GROUP BY dk.ma_dang_ky
    ) AS source
    ON target.ma_dang_ky = source.ma_dang_ky
    WHEN MATCHED THEN
        UPDATE SET ty_le_diem_danh = source.ty_le, 
                   ngay_cap_nhat_ty_le = GETDATE(),
                   ngay_cap_nhat = GETDATE();
END;
GO

_hoc_bong = 3000000,
            diem_trung_binh = @diem_trung_binh,
            ngay_cap_hoc_bong = GETDATE(),
            ghi_chu_hoc_bong = N'Học bổng Khá dựa trên điểm rèn luyện và học tập',
            ngay_cap_nhat = GETDATE()
        WHERE ma_sinh_vien = @ma_sinh_vien
        AND hoc_ky = @hoc_ky
        AND nam_hoc = @nam_hoc;
    END
    ELSE
    BEGIN
        UPDATE DiemRenLuyen
        SET co_hoc_bong = 0,
            loai_hoc_bong = NULL,
            gia_tri_hoc_bong = NULL,
            diem_trung_binh = @diem_trung_binh,
            ngay_cap_nhat = GETDATE()
        WHERE ma_sinh_vien = @ma_sinh_vien
        AND hoc_ky = @hoc_ky
        AND nam_hoc = @nam_hoc;
    END
END;
GOian_SinhVien
ON SinhVien
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE Lop
    SET ngay_cap_nhat = GETDATE()
    FROM Lop l
    INNER JOIN inserted i ON l.ma_lop = i.ma_lop;
END;
GO

CREATE TRIGGER trg_CapHocBong
ON DiemRenLuyen
FOR INSERT, UPDATE
AS
BEGIN
    DECLARE @ma_sinh_vien VARCHAR(10);
    DECLARE @hoc_ky VARCHAR(1);
    DECLARE @nam_hoc VARCHAR(9);
    DECLARE @diem_ren_luyen INT;
    DECLARE @diem_trung_binh DECIMAL(4,2);

    SELECT @ma_sinh_vien = i.ma_sinh_vien, 
           @hoc_ky = i.hoc_ky, 
           @nam_hoc = i.nam_hoc, 
           @diem_ren_luyen = i.diem_cuoi_cung
    FROM inserted i;

    -- Tính điểm trung bình từ bảng DangKyHocPhan thay vì bảng Diem
    SELECT @diem_trung_binh = AVG(d.diem_tong)
    FROM DangKyHocPhan d
    JOIN LopHocPhan lhp ON d.ma_lhp = lhp.ma_lhp
    WHERE d.ma_sinh_vien = @ma_sinh_vien
    AND lhp.hoc_ky = @hoc_ky
    AND lhp.nam_hoc = @nam_hoc;

    IF @diem_ren_luyen >= 90 AND @diem_trung_binh >= 9.0
    BEGIN
        UPDATE DiemRenLuyen
        SET co_hoc_bong = 1,
            loai_hoc_bong = N'Xuất sắc',
            gia_tri_hoc_bong = 5000000,
            diem_trung_binh = @diem_trung_binh,
            ngay_cap_hoc_bong = GETDATE(),
            ghi_chu_hoc_bong = N'Học bổng Xuất sắc dựa trên điểm rèn luyện và học tập',
            ngay_cap_nhat = GETDATE()
        WHERE ma_sinh_vien = @ma_sinh_vien
        AND hoc_ky = @hoc_ky
        AND nam_hoc = @nam_hoc;
    END
    ELSE IF @diem_ren_luyen >= 80 AND @diem_trung_binh >= 8.0
    BEGIN
        UPDATE DiemRenLuyen
        SET co_hoc_bong = 1,
            loai_hoc_bong = N'Khá',
            gia_tri_hoc_bong = 3000000,
            diem_trung_binh = @diem_trung_binh,
            ngay_cap_hoc_bong = GETDATE(),
            ghi_chu_hoc_bong = N'Học bổng Khá dựa trên điểm rèn luyện và học tập',
            ngay_cap_nhat = GETDATE()
        WHERE ma_sinh_vien = @ma_sinh_vien
        AND hoc_ky = @hoc_ky
        AND nam_hoc = @nam_hoc;
    END
    ELSE
    BEGIN
        UPDATE DiemRenLuyen
        SET co_hoc_bong = 0,
            loai_hoc_bong = NULL,
            gia_tri_hoc_bong = NULL,
            diem_trung_binh = @diem_trung_binh,
            ngay_cap_nhat = GETDATE()
        WHERE ma_sinh_vien = @ma_sinh_vien
        AND hoc_ky = @hoc_ky
        AND nam_hoc = @nam_hoc;
    END
END;
-- Stored Procedure tạo buổi học từ lịch
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
    DECLARE @day_of_week INT;
    DECLARE @gio_bat_dau TIME;
    DECLARE @gio_ket_thuc TIME;

    -- Gán thời gian dựa trên tiết học
    SET @gio_bat_dau = CASE @tiet_bat_dau
        WHEN 1 THEN '07:00:00'
        WHEN 2 THEN '07:50:00'
        WHEN 3 THEN '08:40:00'
        WHEN 4 THEN '09:30:00'
        WHEN 5 THEN '10:20:00'
        WHEN 6 THEN '11:10:00'
        WHEN 7 THEN '12:30:00'
        WHEN 8 THEN '13:20:00'
        WHEN 9 THEN '14:10:00'
        WHEN 10 THEN '15:00:00'
        WHEN 11 THEN '15:50:00'
        WHEN 12 THEN '16:40:00'
    END;

    SET @gio_ket_thuc = CASE @tiet_ket_thuc
        WHEN 1 THEN '07:50:00'
        WHEN 2 THEN '08:40:00'
        WHEN 3 THEN '09:30:00'
        WHEN 4 THEN '10:20:00'
        WHEN 5 THEN '11:10:00'
        WHEN 6 THEN '12:00:00'
        WHEN 7 THEN '13:20:00'
        WHEN 8 THEN '14:10:00'
        WHEN 9 THEN '15:00:00'
        WHEN 10 THEN '15:50:00'
        WHEN 11 THEN '16:40:00'
        WHEN 12 THEN '17:30:00'
    END;

    WHILE @current_date <= @ngay_ket_thuc
    BEGIN
        SET @day_of_week = DATEPART(WEEKDAY, @current_date);
        IF (@thu = N'Thứ 2' AND @day_of_week = 2) OR
           (@thu = N'Thứ 3' AND @day_of_week = 3) OR
           (@thu = N'Thứ 4' AND @day_of_week = 4) OR
           (@thu = N'Thứ 5' AND @day_of_week = 5) OR
           (@thu = N'Thứ 6' AND @day_of_week = 6) OR
           (@thu = N'Thứ 7' AND @day_of_week = 7) OR
           (@thu = N'Chủ nhật' AND @day_of_week = 1)
        BEGIN
            INSERT INTO BuoiHoc (ma_lhp, ngay_hoc, gio_bat_dau, gio_ket_thuc, phong_hoc, thu, tiet_bat_dau, tiet_ket_thuc, trang_thai)
            VALUES (@ma_lhp, @current_date, @gio_bat_dau, @gio_ket_thuc, @phong_hoc, @thu, @tiet_bat_dau, @tiet_ket_thuc, N'Chưa diễn ra');
        END
        SET @current_date = DATEADD(DAY, 1, @current_date);
    END
END;
-- Tạo chỉ mục
CREATE NONCLUSTERED INDEX idx_ma_sinh_vien ON DangKyHocPhan(ma_sinh_vien);
CREATE NONCLUSTERED INDEX idx_ma_lhp ON DangKyHocPhan(ma_lhp);
CREATE NONCLUSTERED INDEX idx_ma_buoi ON DiemDanh(ma_buoi);
CREATE NONCLUSTERED INDEX idx_ma_sinh_vien_trang_thai ON DiemDanh(ma_sinh_vien, trang_thai);
CREATE NONCLUSTERED INDEX idx_loai_danh_gia ON DanhGiaSinhVien(loai_danh_gia);
CREATE NONCLUSTERED INDEX idx_ma_sinh_vien_lhp ON DanhGiaSinhVien(ma_sinh_vien, ma_lhp);
CREATE NONCLUSTERED INDEX idx_ma_sinh_vien_diem_ren_luyen ON DiemRenLuyen(ma_sinh_vien);
CREATE NONCLUSTERED INDEX idx_ma_lhp_tai_lieu_hoc_tap ON TaiLieuHocTap(ma_lhp);
CREATE NONCLUSTERED INDEX idx_co_hoc_bong ON DiemRenLuyen(co_hoc_bong) WHERE co_hoc_bong = 1;
GO

-- Tạo View tỷ lệ điểm danh
CREATE VIEW vw_TyLeDiemDanh AS
SELECT 
    sv.ma_sinh_vien,
    sv.ho_ten,
    lhp.ma_lhp,
    mh.ten_mon_hoc,
    dk.ty_le_diem_danh,
    lhp.hoc_ky,
    lhp.nam_hoc
FROM DangKyHocPhan dk
JOIN SinhVien sv ON dk.ma_sinh_vien = sv.ma_sinh_vien
JOIN LopHocPhan lhp ON dk.ma_lhp = lhp.ma_lhp
JOIN MonHoc mh ON lhp.ma_mon_hoc = mh.ma_mon_hoc
WHERE dk.ty_le_diem_danh IS NOT NULL;
GO

-- Tạo View thông tin học bổng
CREATE VIEW vw_ThongTinHocBong AS
SELECT 
    sv.ma_sinh_vien,
    sv.ho_ten,
    sv.ma_lop,
    l.ten_lop,
    dr.hoc_ky,
    dr.nam_hoc,
    dr.loai_hoc_bong,
    dr.gia_tri_hoc_bong,
    dr.diem_cuoi_cung AS diem_ren_luyen,
    dr.diem_trung_binh,
    dr.ngay_cap_hoc_bong
FROM DiemRenLuyen dr
JOIN SinhVien sv ON dr.ma_sinh_vien = sv.ma_sinh_vien
JOIN Lop l ON sv.ma_lop = l.ma_lop
WHERE dr.co_hoc_bong = 1;
GO

-- Thêm view báo cáo tổng hợp kết quả học tập
CREATE VIEW vw_TongHopKetQuaHocTap AS
SELECT 
    sv.ma_sinh_vien,
    sv.ho_ten,
    l.ma_lop,
    l.ten_lop,
    n.ma_nganh,
    n.ten_nganh,
    k.ma_khoa,
    k.ten_khoa,
    lhp.hoc_ky,
    lhp.nam_hoc,
    mh.ma_mon_hoc,
    mh.ten_mon_hoc,
    mh.so_tin_chi,
    dk.diem_giua_ky,
    dk.diem_thuc_hanh,
    dk.diem_cuoi_ky,
    dk.diem_tong,
    dk.diem_chu,
    dk.ty_le_diem_danh
FROM SinhVien sv
JOIN Lop l ON sv.ma_lop = l.ma_lop
JOIN NganhHoc n ON sv.ma_nganh = n.ma_nganh
JOIN Khoa k ON sv.ma_khoa = k.ma_khoa
JOIN DangKyHocPhan dk ON sv.ma_sinh_vien = dk.ma_sinh_vien
JOIN LopHocPhan lhp ON dk.ma_lhp = lhp.ma_lhp
JOIN MonHoc mh ON lhp.ma_mon_hoc = mh.ma_mon_hoc
WHERE dk.trang_thai = N'Hoàn thành' OR dk.trang_thai = N'Đang học';
GO

-- Thêm view tổng hợp thái độ học tập và vi phạm
CREATE VIEW vw_ThongKeDanhGiaSinhVien AS
SELECT 
    sv.ma_sinh_vien,
    sv.ho_ten,
    sv.ma_lop,
    l.ten_lop,
    dg.loai_danh_gia,
    CASE 
        WHEN dg.loai_danh_gia = N'Thái độ học tập' THEN mh.ten_mon_hoc
        ELSE NULL
    END AS ten_mon_hoc,
    dg.ngay_danh_gia,
    CASE 
        WHEN dg.loai_danh_gia = N'Thái độ học tập' THEN dg.muc_do_tap_trung
        ELSE NULL
    END AS muc_do_tap_trung,
    CASE 
        WHEN dg.loai_danh_gia = N'Vi phạm kỷ luật' THEN dg.loai_vi_pham
        ELSE NULL
    END AS loai_vi_pham,
    CASE 
        WHEN dg.loai_danh_gia = N'Vi phạm kỷ luật' THEN dg.muc_do_vi_pham
        ELSE NULL
    END AS muc_do_vi_pham,
    gv.ho_ten AS nguoi_danh_gia
FROM DanhGiaSinhVien dg
JOIN SinhVien sv ON dg.ma_sinh_vien = sv.ma_sinh_vien
JOIN Lop l ON sv.ma_lop = l.ma_lop
JOIN GiangVien gv ON dg.ma_nguoi_danh_gia = gv.ma_giang_vien
LEFT JOIN LopHocPhan lhp ON dg.ma_lhp = lhp.ma_lhp
LEFT JOIN MonHoc mh ON lhp.ma_mon_hoc = mh.ma_mon_hoc;
GO

PRINT N'Đã tạo cơ sở dữ liệu [BTLSQL-ThaiDoHocTapSv] với cấu trúc tối ưu thành công';
GO

-- Stored Procedure tính điểm rèn luyện (đã điều chỉnh)
CREATE PROCEDURE sp_TinhDiemRenLuyen
    @ma_sinh_vien VARCHAR(10),
    @hoc_ky VARCHAR(1),
    @nam_hoc VARCHAR(9),
    @diem_thai_do INT,
    @ma_nguoi_danh_gia VARCHAR(10) = 'GV001'
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra sinh viên tồn tại
    IF NOT EXISTS (SELECT 1 FROM SinhVien WHERE ma_sinh_vien = @ma_sinh_vien)
    BEGIN
        THROW 50007, N'Sinh viên không tồn tại', 1;
        RETURN;
    END

    -- Kiểm tra học kỳ hợp lệ
    IF @hoc_ky NOT IN ('1', '2')
    BEGIN
        THROW 50008, N'Học kỳ không hợp lệ', 1;
        RETURN;
    END

    -- Kiểm tra năm học hợp lệ
    IF @nam_hoc NOT LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'
       OR CAST(SUBSTRING(@nam_hoc, 6, 4) AS INT) != CAST(SUBSTRING(@nam_hoc, 1, 4) AS INT) + 1
    BEGIN
        THROW 50009, N'Năm học không hợp lệ', 1;
        RETURN;
    END

    -- Kiểm tra giảng viên đánh giá
    IF NOT EXISTS (SELECT 1 FROM GiangVien WHERE ma_giang_vien = @ma_nguoi_danh_gia)
    BEGIN
        THROW 50010, N'Giảng viên đánh giá không tồn tại', 1;
        RETURN;
    END

    -- Tính số vi phạm từ bảng DanhGiaSinhVien thay vì ViPhamKyLuat
    DECLARE @so_vi_pham INT;
    SET @so_vi_pham = (
        SELECT COUNT(*)
        FROM DanhGiaSinhVien dgSV
        WHERE dgSV.ma_sinh_vien = @ma_sinh_vien
        AND dgSV.loai_danh_gia = N'Vi phạm kỷ luật'
        AND YEAR(dgSV.ngay_danh_gia) = CAST(SUBSTRING(@nam_hoc, 1, 4) AS INT)
    );

    -- Tính điểm cuối cùng, đảm bảo không âm
    DECLARE @diem_cuoi_cung INT;
    SET @diem_cuoi_cung = COALESCE(@diem_thai_do, 80) - (@so_vi_pham * 5);
    IF @diem_cuoi_cung < 0
        SET @diem_cuoi_cung = 0;

    -- Tính xếp loại
    DECLARE @xep_loai NVARCHAR(20);
    SET @xep_loai = CASE 
        WHEN @diem_cuoi_cung >= 90 THEN N'Xuất sắc'
        WHEN @diem_cuoi_cung >= 80 THEN N'Tốt'
        WHEN @diem_cuoi_cung >= 70 THEN N'Khá'
        WHEN @diem_cuoi_cung >= 60 THEN N'Trung bình'
        WHEN @diem_cuoi_cung >= 50 THEN N'Yếu'
        ELSE N'Kém'
    END;

    -- Cập nhật hoặc chèn bản ghi
    IF EXISTS (
        SELECT 1 
        FROM DiemRenLuyen 
        WHERE ma_sinh_vien = @ma_sinh_vien 
        AND hoc_ky = @hoc_ky 
        AND nam_hoc = @nam_hoc
    )
    BEGIN
        UPDATE DiemRenLuyen
        SET diem_cuoi_cung = @diem_cuoi_cung,
            xep_loai = @xep_loai,
            ma_nguoi_danh_gia = @ma_nguoi_danh_gia,
            ngay_danh_gia = GETDATE(),
            ngay_cap_nhat = GETDATE()
        WHERE ma_sinh_vien = @ma_sinh_vien
        AND hoc_ky = @hoc_ky
        AND nam_hoc = @nam_hoc;
    END
    ELSE
    BEGIN
        INSERT INTO DiemRenLuyen (ma_sinh_vien, hoc_ky, nam_hoc, diem_cuoi_cung, xep_loai, ma_nguoi_danh_gia, ngay_danh_gia)
        VALUES (
            @ma_sinh_vien, 
            @hoc_ky, 
            @nam_hoc, 
            @diem_cuoi_cung, 
            @xep_loai, 
            @ma_nguoi_danh_gia, 
            GETDATE()
        );
    END
END;
GO

-- Trigger tự động cập nhật ngay_cap_nhat cho Khoa
CREATE TRIGGER trg_CapNhat_ThoiGian_SinhVien
ON SinhVien
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
AS
BEGIN
    UPDATE Lop
    SET ngay_cap_nhat = GETDATE()
    FROM Lop l
    INNER JOIN inserted i ON l.ma_lop = i.ma_lop;
END;
GO-- Thêm dữ liệu cho bảng Sinh viên
INSERT INTO SinhVien (ma_sinh_vien, ho_ten, ngay_sinh, gioi_tinh, email, ten_dang_nhap, mat_khau_bam, so_dien_thoai, dia_chi, cccd, thong_tin_phu_huynh, ma_lop, ma_nganh, ma_khoa, nam_nhap_hoc, trang_thai)
VALUES 
('SV001', N'Nguyễn Văn Hùng', '2003-05-10', N'Nam', 'SV001@st.utc2.edu.vn', 'nguyenvanhung', 'hashed_password_1', '0911111111', N'Hà Nội', '123456789012', N'Nguyễn Văn Ba', 'CNPM01', 'CNPM', 'CNTT', 2023, N'Đang học'),
('SV002', N'Trần Thị Mai', '2003-07-15', N'Nữ', 'SV002@st.utc2.edu.vn', 'tranthimai', 'hashed_password_2', '0922222222', N'Hà Nội', '123456789013', N'Trần Văn An', 'CNPM01', 'CNPM', 'CNTT', 2023, N'Đang học'),
('SV003', N'Lê Văn Nam', '2003-03-20', N'Nam', 'SV003@st.utc2.edu.vn', 'levannam', 'hashed_password_3', '0933333333', N'TP.HCM', '123456789014', N'Lê Thị Hoa', 'KTPM01', 'KTPM', 'CNTT', 2023, N'Đang học'),
('SV004', N'Phạm Thị Lan', '2003-09-25', N'Nữ', 'SV004@st.utc2.edu.vn', 'phamthilan', 'hashed_password_4', '0944444444', N'Đà Nẵng', '123456789015', N'Phạm Văn Tâm', 'XDDD01', 'XDDD', 'KTXD', 2023, N'Đang học'),
('SV005', N'Hoàng Văn Tùng', '2003-11-30', N'Nam', 'SV005@st.utc2.edu.vn', 'hoangvantung', 'hashed_password_5', '0955555555', N'Hà Nội', '123456789016', N'Hoàng Thị Mai', 'CNCK01', 'CNCK', 'KTCK', 2023, N'Đang học'),
('SV006', N'Ngô Thị Hoa', '2003-01-12', N'Nữ', 'SV006@st.utc2.edu.vn', 'ngothihoa', 'hashed_password_6', '0966666666', N'Hải Phòng', '123456789017', N'Ngô Văn Long', 'OTOKT01', 'OTOKT', 'KTOTO', 2023, N'Đang học'),
('SV007', N'Vũ Văn Long', '2003-06-18', N'Nam', 'SV007@st.utc2.edu.vn', 'vuvanlong', 'hashed_password_7', '0977777777', N'Hà Nội', '123456789018', N'Vũ Thị Hương', 'QTKD01', 'QTKD', 'QTKD', 2023, N'Đang học');
-- Thêm dữ liệu cho bảng Môn học
INSERT INTO MonHoc (ma_mon_hoc, ten_mon_hoc, so_tin_chi, ma_khoa, mo_ta)
VALUES 
('TH01', N'Lập trình C++', 3, 'CNTT', N'Môn học về lập trình C++ cơ bản'),
('TH02', N'Cấu trúc dữ liệu', 3, 'CNTT', N'Môn học về cấu trúc dữ liệu và giải thuật'),
('XD01', N'Cơ sở kỹ thuật xây dựng', 3, 'KTXD', N'Môn học về kỹ thuật xây dựng cơ bản'),
('CK01', N'Cơ học chất rắn', 3, 'KTCK', N'Môn học về cơ học chất rắn'),
('OT01', N'Hệ thống động cơ ô tô', 3, 'KTOTO', N'Môn học về hệ thống động cơ ô tô'),
('QT01', N'Quản trị kinh doanh cơ bản', 3, 'QTKD', N'Môn học về quản trị kinh doanh cơ bản');
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

-- Thêm dữ liệu cho bảng DanhGiaSinhVien (thay thế cho ThaiDoHocTap)
INSERT INTO DanhGiaSinhVien (ma_sinh_vien, loai_danh_gia, ma_lhp, ty_le_tham_gia, muc_do_tap_trung, hoan_thanh_bai_tap, tham_gia_thao_luan, tinh_chu_dong, lam_viec_nhom, ton_trong, ma_nguoi_danh_gia, ngay_danh_gia)
VALUES 
('SV001', N'Thái độ học tập', 'TH01_2024_1', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', 'GV001', '2024-09-15'),
('SV002', N'Thái độ học tập', 'TH01_2024_1', 95, N'Xuất sắc', 90, 9, N'Chủ động', N'Tốt', N'Tốt', 'GV001', '2024-09-15'),
('SV003', N'Thái độ học tập', 'TH02_2024_1', 80, N'Khá', 75, 7, N'Trung bình', N'Khá', N'Khá', 'GV006', '2024-09-15'),
('SV004', N'Thái độ học tập', 'XD01_2024_1', 85, N'Tốt', 80, 8, N'Chủ động', N'Tốt', N'Tốt', 'GV002', '2024-09-15'),
('SV005', N'Thái độ học tập', 'CK01_2024_1', 90, N'Tốt', 85, 8, N'Chủ động', N'Tốt', N'Tốt', 'GV003', '2024-09-15');
GO

-- Thêm dữ liệu cho bảng DanhGiaSinhVien (thay thế cho ViPhamKyLuat)
INSERT INTO DanhGiaSinhVien (ma_sinh_vien, loai_danh_gia, ngay_danh_gia, loai_vi_pham, muc_do_vi_pham, bien_phap_xu_ly, ma_nguoi_danh_gia, ghi_chu)
VALUES 
('SV003', N'Vi phạm kỷ luật', '2024-09-05', N'Đi muộn buổi học', N'Nhẹ', N'Nhắc nhở', 'GV006', N'Đi muộn 15 phút'),
('SV007', N'Vi phạm kỷ luật', '2024-09-07', N'Sao chép bài tập', N'Trung bình', N'Khiển trách', 'GV005', N'Sao chép bài tập của bạn');
GO

-- Thêm dữ liệu cho bảng DiemRenLuyen
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

-- Cập nhật thông tin học bổng
UPDATE DiemRenLuyen
SET co_hoc_bong = 1,
    loai_hoc_bong = N'Xuất sắc',
    gia_tri_hoc_bong = 5000000,
    diem_trung_binh = 9.0,
    ngay_cap_hoc_bong = '2024-09-25',
    ghi_chu_hoc_bong = N'Học bổng Xuất sắc kỳ 1'
WHERE ma_sinh_vien IN ('SV001', 'SV002', 'SV005', 'SV006') AND hoc_ky = '1' AND nam_hoc = '2024-2025';

UPDATE DiemRenLuyen
SET co_hoc_bong = 1,
    loai_hoc_bong = N'Khá',
    gia_tri_hoc_bong = 3000000,
    diem_trung_binh = 8.5,
    ngay_cap_hoc_bong = '2024-09-25',
    ghi_chu_hoc_bong = N'Học bổng Khá kỳ 1'
WHERE ma_sinh_vien = 'SV004' AND hoc_ky = '1' AND nam_hoc = '2024-2025';
GO

-- Thêm dữ liệu cho bảng Tài liệu học tập
INSERT INTO TaiLieuHocTap (ma_lhp, tieu_de, duong_dan, ma_nguoi_tai_len, mo_ta)
VALUES 
('TH01_2024_1', N'Tài liệu lập trình C++ cơ bản', '/tai_lieu/cpp_basic.pdf', 'GV001', N'Tài liệu giới thiệu lập trình C++'),
('TH02_2024_1', N'Cấu trúc dữ liệu và giải thuật', '/tai_lieu/data_structure.pdf', 'GV006', N'Tài liệu về mảng và con trỏ'),
('XD01_2024_1', N'Cơ sở kỹ thuật xây dựng', '/tai_lieu/xd_basic.pdf', 'GV002', N'Tài liệu cơ bản về kỹ thuật xây dựng'),
('CK01_2024_1', N'Cơ học chất rắn', '/tai_lieu/co_hoc_chat_ran.pdf', 'GV003', N'Tài liệu cơ học chất rắn'),
('OT01_2024_1', N'Hệ thống động cơ ô tô', '/tai_lieu/dong_co_oto.pdf', 'GV004', N'Tài liệu về hệ thống động cơ ô tô'),
('QT01_2024_1', N'Quản trị kinh doanh cơ bản', '/tai_lieu/qt_basic.pdf', 'GV005', N'Tài liệu giới thiệu quản trị kinh doanh');
GO

-- Cập nhật điểm cho DangKyHocPhan
UPDATE DangKyHocPhan
SET diem_giua_ky = 8.5, diem_cuoi_ky = 9.0, diem_thuc_hanh = 8.0, trang_thai_diem = N'Đã duyệt'
WHERE ma_dang_ky = 1;

UPDATE DangKyHocPhan
SET diem_giua_ky = 9.0, diem_cuoi_ky = 9.5, diem_thuc_hanh = 8.5, trang_thai_diem = N'Đã duyệt'
WHERE ma_dang_ky = 2;

UPDATE DangKyHocPhan
SET diem_giua_ky = 7.5, diem_cuoi_ky = 8.0, diem_thuc_hanh = 7.0, trang_thai_diem = N'Đã duyệt'
WHERE ma_dang_ky = 3;

UPDATE DangKyHocPhan
SET diem_giua_ky = 8.0, diem_cuoi_ky = 8.5, diem_thuc_hanh = 7.5, trang_thai_diem = N'Đã duyệt'
WHERE ma_dang_ky = 4;

UPDATE DangKyHocPhan
SET diem_giua_ky = 8.5, diem_cuoi_ky = 9.0, diem_thuc_hanh = 8.0, trang_thai_diem = N'Đã duyệt'
WHERE ma_dang_ky = 5;

UPDATE DangKyHocPhan
SET diem_giua_ky = 9.0, diem_cuoi_ky = 9.5, diem_thuc_hanh = 8.5, trang_thai_diem = N'Đã duyệt'
WHERE ma_dang_ky = 6;

UPDATE DangKyHocPhan
SET diem_giua_ky = 7.5, diem_cuoi_ky = 8.0, diem_thuc_hanh = 7.0, trang_thai_diem = N'Đã duyệt'
WHERE ma_dang_ky = 7;
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
INSERT INTO BuoiHoc (ma_lhp, ngay_hoc, gio_bat_dau, gio_ket_thuc, phong_hoc, thu, tiet_bat_dau, tiet_ket_thuc, chu_de, trang_thai)
VALUES 
('TH01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'A101', N'Thứ 3', 1, 3, N'Giới thiệu lập trình C++', N'Đã diễn ra'),
('TH02_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'A102', N'Thứ 3', 4, 6, N'Mảng và con trỏ', N'Đã diễn ra'),
('XD01_2024_1', '2024-09-10', '13:00:00', '15:00:00', 'B201', N'Thứ 3', 7, 9, N'Cơ sở kỹ thuật xây dựng', N'Đã diễn ra'),
('CK01_2024_1', '2024-09-10', '15:30:00', '17:30:00', 'C301', N'Thứ 3', 10, 12, N'Cơ học chất rắn', N'Đã diễn ra'),
('OT01_2024_1', '2024-09-10', '07:00:00', '09:00:00', 'D401', N'Thứ 3', 1, 3, N'Hệ thống động cơ ô tô', N'Đã diễn ra'),
('QT01_2024_1', '2024-09-10', '09:30:00', '11:30:00', 'E501', N'Thứ 3', 4, 6, N'Khái niệm quản trị', N'Đã diễn ra');
GO-