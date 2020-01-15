@[Link("exif")]
lib LibExif
  type ExifEntry = Void*
  type ExifContent = Void*

  enum ExifTag
    EXIF_TAG_DATE_TIME_ORIGINAL = 0x9003
  end

  enum ExifIfd
    EXIF_IFD_0
    EXIF_IFD_1
    EXIF_IFD_EXIF
    EXIF_IFD_GPS
    EXIF_IFD_INTEROPERABILITY
    EXIF_IFD_COUNT
  end

  struct ExifData
    size : UInt32
    ifd : ExifContent*[ExifIfd::EXIF_IFD_COUNT]
  end

  fun exif_data_new_from_file(path : UInt8*) : ExifData*
  fun exif_data_dump(data : ExifData*)
  fun exif_content_get_entry(content : ExifContent*, tag : ExifTag) : ExifEntry*
  fun exif_entry_get_value(entry : ExifEntry*, value : LibC::Char*, maxlen : LibC::SizeT) : LibC::Char*

  fun exif_data_unref(data : ExifData*)

  fun exif_entry_dump(entry : ExifEntry*, indent : LibC::UInt)
  fun exif_content_dump(content : ExifContent*, indent : LibC::UInt)
end
