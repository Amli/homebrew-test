class GdalAT240 < Formula
  desc "Geospatial Data Abstraction Library"
  homepage "https://www.gdal.org/"
  url "https://download.osgeo.org/gdal/2.4.0/gdal-2.4.0.tar.xz"
  sha256 "c3791dcc6d37e59f6efa86e2df2a55a4485237b0a48e330ae08949f0cdf00f27"
  revision 3

  bottle do
    sha256 mojave:      "b79609600f00feb24d178d211f721a8aa47de6ff6948e75609f1ed9f60ac65f7"
    sha256 high_sierra: "f08f3ffd6473fbc26497d8877f0aafbf803d28b2c59405bf705809ea5e91d55a"
    sha256 sierra:      "06da56a632bf5ba9719da43c203f09579bad1032b655f9a6bab57ec5c41b2218"
  end

  head do
    url "https://github.com/OSGeo/gdal.git"
    depends_on "doxygen" => :build
  end

  keg_only :versioned_formula

  depends_on "cfitsio"
  depends_on "epsilon"
  depends_on "expat"
  depends_on "freexl"
  depends_on "geos"
  depends_on "giflib"
  depends_on "hdf5"
  depends_on "jasper"
  depends_on "jpeg"
  depends_on "json-c"
  depends_on "libdap"
  depends_on "libgeotiff"
  depends_on "libpng"
  depends_on "libpq"
  depends_on "libspatialite"
  depends_on "libtiff"
  depends_on "libxml2"
  depends_on "netcdf"
  depends_on "numpy"
  depends_on "pcre"
  depends_on "podofo"
  depends_on "poppler"
  depends_on "proj"
  depends_on "python"
  depends_on "sqlite" # To ensure compatibility with SpatiaLite
  depends_on "unixodbc" # macOS version is not complete enough
  depends_on "webp"
  depends_on "xerces-c"
  depends_on "xz" # get liblzma compression algorithm library from XZutils
  depends_on "zstd"

  def install
    args = [
      # Base configuration
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--with-libtool",
      "--with-local=#{prefix}",
      "--with-opencl",
      "--with-threads",

      # GDAL native backends
      "--with-bsb",
      "--with-grib",
      "--with-pam",
      "--with-pcidsk=internal",
      "--with-pcraster=internal",

      # Homebrew backends
      "--with-curl=/usr/bin/curl-config",
      "--with-expat=#{Formula["expat"].prefix}",
      "--with-freexl=#{Formula["freexl"].opt_prefix}",
      "--with-geos=#{Formula["geos"].opt_prefix}/bin/geos-config",
      "--with-geotiff=#{Formula["libgeotiff"].opt_prefix}",
      "--with-gif=#{Formula["giflib"].opt_prefix}",
      "--with-jpeg=#{Formula["jpeg"].opt_prefix}",
      "--with-libjson-c=#{Formula["json-c"].opt_prefix}",
      "--with-libtiff=#{Formula["libtiff"].opt_prefix}",
      "--with-pg=#{Formula["libpq"].opt_prefix}/bin/pg_config",
      "--with-png=#{Formula["libpng"].opt_prefix}",
      "--with-spatialite=#{Formula["libspatialite"].opt_prefix}",
      "--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
      "--with-proj=#{Formula["proj"].opt_prefix}",
      "--with-zstd=#{Formula["zstd"].opt_prefix}",
      "--with-liblzma=yes",
      "--with-cfitsio=/usr/local",
      "--with-hdf5=/usr/local",
      "--with-netcdf=/usr/local",
      "--with-jasper=/usr/local",
      "--with-xerces=/usr/local",
      "--with-odbc=/usr/local",
      "--with-dods-root=/usr/local",
      "--with-epsilon=/usr/local",
      "--with-webp=/usr/local",
      "--with-podofo=/usr/local",

      # Explicitly disable some features
      "--with-armadillo=no",
      "--with-qhull=no",
      "--without-grass",
      "--without-jpeg12",
      "--without-libgrass",
      "--without-mysql",
      "--without-perl",
      "--without-php",
      "--without-python",
      "--without-ruby",

      # Unsupported backends are either proprietary or have no compatible version
      # in Homebrew. Podofo is disabled because Poppler provides the same
      # functionality and then some.
      "--without-gta",
      "--without-ogdi",
      "--without-fme",
      "--without-hdf4",
      "--without-openjpeg",
      "--without-fgdb",
      "--without-ecw",
      "--without-kakadu",
      "--without-mrsid",
      "--without-jp2mrsid",
      "--without-mrsid_lidar",
      "--without-msg",
      "--without-oci",
      "--without-ingres",
      "--without-dwgdirect",
      "--without-idb",
      "--without-sde",
      "--without-podofo",
      "--without-rasdaman",
      "--without-sosi",
    ]

    # Work around "error: no member named 'signbit' in the global namespace"
    if DevelopmentTools.clang_build_version >= 900
      ENV.delete "SDKROOT"
      ENV.delete "HOMEBREW_SDKROOT"
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    if build.stable? # GDAL 2.3 handles Python differently
      cd "swig/python" do
        system "python3", *Language::Python.setup_install_args(prefix)
      end
      bin.install Dir["swig/python/scripts/*.py"]
    end

    system "make", "man" if build.head?
    # Force man installation dir: https://trac.osgeo.org/gdal/ticket/5092
    system "make", "install-man", "INST_MAN=#{man}"
    # Clean up any stray doxygen files
    Dir.glob("#{bin}/*.dox") { |p| rm p }
  end

  test do
    # basic tests to see if third-party dylibs are loading OK
    system "#{bin}/gdalinfo", "--formats"
    system "#{bin}/ogrinfo", "--formats"
    system "python3", "-c", "import gdal" if build.stable? # GDAL 2.3 handles Python differently
  end
end
