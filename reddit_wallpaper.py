import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse
from io import BytesIO
from PIL import Image

import logging
logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)

session = requests.Session()
session.headers.update({
    'User-Agent':(
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) '
        'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
    )
})

log.info("Collecting wallpapers home...")
home = session.get("https://www.reddit.com/r/wallpapers/")
soup = BeautifulSoup(home.text, 'html.parser')

wallpaper_path = os.path.join(os.environ["HOME"], "Pictures", "wallpaper")

image_url = "https://i.redd.it{}"
for img in soup.findAll("img"):
    if img.attrs["alt"] == "Post image":

        url = urlparse(img.attrs["src"])

        # Download the image
        log.info("Downloaded image {}".format(url.path))
        payload = session.get(image_url.format(url.path))
        image = Image.open(BytesIO(payload.content))

        width, height = image.size
        ar = width / height

        log.debug("Image stats: {} {} {}".format(width, height, ar))

        if width >= 1920 and ar > 1.2:
            # Save the image
            with open(wallpaper_path, "wb") as handle:
                image.save(handle, format=image.format.lower())
            os.system("gsettings set org.gnome.desktop.background picture-uri file://{}".format(wallpaper_path))
            log.info("New wallpaper set")
            break

log.info("Complete")