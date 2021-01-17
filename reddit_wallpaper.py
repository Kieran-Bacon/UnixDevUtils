import argparse
import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse
from io import BytesIO
from PIL import Image
import urllib3
import time

import logging
logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger(__name__)


cli = argparse.ArgumentParser("Reddit Wallpaper")
cli.add_argument(
    "--wallpaper-location",
    default=os.path.join(os.environ.get("HOME", "root"), "Pictures", "wallpaper"),
    help="Path location for the wallpaper to be stored and assigned in the user settings"
)
cli.add_argument(
    "--log-file",
    help="Path location for the wallpaper to be stored and assigned in the user settings"
)

args = cli.parse_args()

if args.log_file:
    hdlr = logging.FileHandler(args.log_file, mode="w")
    formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    hdlr.setFormatter(formatter)
    log.addHandler(hdlr)

try:
    session = requests.Session()
    session.headers.update({
        'User-Agent':(
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) '
            'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'
        )
    })

    log.info("Collecting wallpapers home...")
    for _ in range(3):
        try:
            home = session.get("https://www.reddit.com/r/wallpapers/")
            break
        except:
            log.exception("Couldn't collect reddit home page")
            time.sleep(10)

    soup = BeautifulSoup(home.text, 'html.parser')

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
                with open(args.wallpaper_location, "wb") as handle:
                    image.save(handle, format=image.format.lower())
                os.system("gsettings set org.gnome.desktop.background picture-uri file://{}".format(args.wallpaper_location))
                log.info("New wallpaper set")
                break

    log.info("Complete")
except:
    log.exception("Failed to setup new wallpaper")