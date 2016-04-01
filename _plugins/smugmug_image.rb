# SmugImage
# Author: Will Pimblett, March 2016
#
# Get a single SM image in many sizes with liquid support

require_relative 'smugmug'

class SmugImage < Smug

  SIZES = [
    'ImageSizeTiny',
    'ImageSizeThumb',
    'ImageSizeSmall',
    'ImageSizeMedium',
    'ImageSizeLarge',
    'ImageSizeXLarge',
    'ImageSizeX2Large',
    'ImageSizeX3Large',
    'ImageSizeOriginal',
  ]

  def initialize(imageID)
    @imageID = imageID
    imageSizeDetails # Prefetch data
  end

  def fetchImageSizeDetails
    # Fetch ISD from API
    Jekyll.logger.info "Fetching SM Image:", "#{ @imageID }, many sizes"
    url = api_url("image/#{ @imageID }!sizedetails")
    data = self.class.get(url)
    if data.key? "Response"
      return data["Response"]["ImageSizeDetails"]
    else
      Jekyll.logger.error "SM Error:", "Invalid ImageSizeDetails response"
    end
  end

  def getImageSizeDetails
    # Attempt fetch from cache
    isd = cache_fetch(@imageID)

    if not isd and api_key
      # Not in cache, fetch new and save to cache
      isd = fetchImageSizeDetails
      if isd then cache_save(@imageID, isd) end
    elsif not isd and not api_key
      Jekyll.logger.error "SM Skip:",  "No API key"
    end

    return isd
  end

  def imageSizeDetails
    @isd ||= getImageSizeDetails
  end

  def getSize(size)
    if imageSizeDetails.key? size
      imageSizeDetails[size]["Url"]
    else
      getSize(SIZES[SIZES.index(size) - 1])
    end
  end

  def customSize(size)
    imageSizeDetails["ImageUrlTemplate"].gsub("\#size\#", size)
  end

  def to_liquid
    if @isd
      {
        "tiny" => getSize("ImageSizeTiny"),
        "thumb" => getSize("ImageSizeThumb"),
        "small" => getSize("ImageSizeSmall"),
        "medium" => getSize("ImageSizeMedium"),
        "large" => getSize("ImageSizeLarge"),
        "xlarge" => getSize("ImageSizeXLarge"),
        "x2large" => getSize("ImageSizeX2Large"),
        "x3large" => getSize("ImageSizeX3Large"),
        "original" => getSize("ImageSizeOriginal"),

        "person_list" => customSize("41x41!"),
        "person_bio" => customSize("160x160!"),
        "person_search" => customSize("140x140!"),
      }
    else
      return nil
    end
  end

end
