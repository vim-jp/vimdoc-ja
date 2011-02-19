# encoding: utf-8
# require: http://code.google.com/p/gdata-python-client/

from __future__ import print_function, division, unicode_literals, \
        absolute_import

import sys
import os
import codecs
import getpass

sys.path.insert(0, 'gdata-2.0.13.zip/gdata-2.0.13/src')
import gdata.client
import gdata.sites.client
import atom


SOURCE_APP_NAME = "vimdocja-updater-v1.1"

RETRY_MAX = 3


def is_helphtml(page_name):
    return page_name.endswith("-html") or page_name == "home"


def pagetitle(page_name):
    if page_name == "home":
        return "help"
    return page_name.replace("-html", "")


def main():
    srcdir = "tmp"
    site = raw_input("site: ")
    email = raw_input("email: ")
    password = getpass.getpass("password: ")

    client = gdata.sites.client.SitesClient(site)
    client.client_login(email, password, SOURCE_APP_NAME)

    entries = {}
    uri = "{0}?kind={1}".format(client.MakeContentFeedUri(), "webpage")
    feed = client.GetContentFeed(uri=uri)
    while True:
        for entry in feed.entry:
            page_name = entry.page_name.text
            print("fetch: {0}".format(page_name))
            if is_helphtml(page_name):
                entries[page_name] = entry
        if feed.find_next_link() is None:
            break
        feed = client.GetNext(feed)

    for page_name in sorted(os.listdir(srcdir)):
        if is_helphtml(page_name):
            with open(os.path.join(srcdir, page_name)) as f:
                content = f.read()
            if page_name in entries:
                print("update: {0}".format(page_name))
                entry = entries.pop(page_name)
                entry.title = atom.data.Title(text=pagetitle(page_name))
                entry.content = atom.data.Content(text=content)
                for _retry in range(RETRY_MAX):
                    try:
                        client.Update(entry)
                    except gdata.client.RequestError:
                        print("RequestError: retry")
                        continue
                    break
            else:
                print("create: {0}".format(page_name))
                for _retry in range(RETRY_MAX):
                    try:
                        entry = client.CreatePage("webpage", page_name,
                                html=content, page_name=page_name)
                    except gdata.client.RequestError:
                        print("RequestError: retry")
                        continue
                    break

    for entry in entries.values():
        print("delete: {0}".format(entry.page_name.text))
        for _retry in range(RETRY_MAX):
            try:
                client.Delete(entry)
            except gdata.client.RequestError:
                print("RequestError: retry")
                continue
            break


if __name__ == "__main__":
    # not work with raw_input()
    #sys.stdin = codecs.getreader(sys.getfilesystemencoding())(sys.stdin)
    sys.stdout = codecs.getwriter(sys.getfilesystemencoding())(sys.stdout)
    sys.stderr = codecs.getwriter(sys.getfilesystemencoding())(sys.stderr)
    main()
