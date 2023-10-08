# System imports
import datetime
import difflib
import hashlib
import json
import pathlib
import re
import subprocess
import sys
import urllib
import urllib.request
import zipfile

from pathlib import Path


################################################################################
## Stuff
BASE_RELEASE_URL = "https://github.com/PortsMaster/PortMaster-Releases/releases/latest/download/"


TODAY = str(datetime.datetime.today().date())
################################################################################

################################################################################
## Port Information

PORT_INFO_ROOT_ATTRS = {
    'version': 2,
    'name': None,
    'items': None,
    'items_opt': None,
    'attr': {},
    # 'status': None,
    # 'files': None,
    }

PORT_INFO_ATTR_ATTRS = {
    'title': "",
    'desc': "",
    'inst': "",
    'genres': [],
    'porter': [],
    'image': None,
    'rtr': False,
    'runtime': None,
    'reqs': [],
    }


PORT_INFO_GENRES = [
    "action",
    "adventure",
    "arcade",
    "casino/card",
    "fps",
    "platformer",
    "puzzle",
    "racing",
    "rhythm",
    "rpg",
    "simulation",
    "sports",
    "strategy",
    "visual novel",
    "other",
    ]


PORT_IMAGES = [
    "screenshot",
    "cover",
    "thumbnail",
    "video",
    ]


PORT_IMAGES_REQ = [
    "screenshot",
    ]


def fetch_text(url):
    try:
        # Open the URL
        with urllib.request.urlopen(url) as response:
            # Read the content of the file
            file_content = response.read()

        # Decode the bytes to a string (assuming the file is in UTF-8 encoding)
        return file_content.decode('utf-8')

    except urllib.error.URLError as err:
        print(f"Unable to download {url}: {err}")
        return None

    except UnicodeDecodeError as err:
        return None


def fetch_json(url):
    text = fetch_text(url)
    if text is None:
        return None

    try:
        return json.loads(text)

    except json.decoder.JSONDecodeError as err:
        return None


def hash_file(file_name):
    if isinstance(file_name, str):
        file_name = pathlib.Path(file_name)
    elif not isinstance(file_name, pathlib.PurePath):
        raise ValueError(file_name)

    if not file_name.is_file():
        return None

    md5 = hashlib.md5()
    with file_name.open('rb') as fh:
        md5.update(fh.read())

    return md5.hexdigest()


def runtime_nicename(runtime):
    if runtime.startswith("frt"):
        return ("Godot/FRT {version}").format(version=runtime.split('_', 1)[1].rsplit('.', 1)[0])

    if runtime.startswith("mono"):
        return ("Mono {version}").format(version=runtime.split('-', 1)[1].rsplit('-', 1)[0])

    if "jdk" in runtime and runtime.startswith("zulu11"):
        return ("JDK {version}").format(version=runtime.split('-')[2][3:])

    return runtime


def name_cleaner(text):
    temp = re.sub(r'[^a-zA-Z0-9 _\-\.]+', '', text.strip().lower())
    return re.sub(r'[ \.]+', '.', temp)


def oc_join(strings):
    """
    Oxford comma join
    """
    if len(strings) == 0:
        return ""

    elif len(strings) == 1:
        return strings[0]

    elif len(strings) == 2:
        return f"{strings[0]} and {strings[1]}"

    else:
        oxford_comma_list = ", ".join(strings[:-1]) + ", and " + strings[-1]
        return oxford_comma_list


def port_info_to_portmd(port_info, file_name):
    def nice_value(value):
        if value is None:
            return ""
        if value == "None":
            return ""
        return value.replace("\n", "\\n")

    output = []

    if 'opengl' in port_info["attr"]["reqs"]:
        output.append(f'Title_F="{port_info["attr"]["title"].replace(" ", "_")} ."')

    elif 'power' in port_info["attr"]['reqs']:
        output.append(f'Title_P="{port_info["attr"]["title"].replace(" ", "_")} ."')

    else:
        output.append(f'Title="{port_info["attr"]["title"].replace(" ", "_")} ."')

    if port_info["attr"].get("inst", "") not in ("", None):
        output.append(f'Desc="{nice_value(port_info["attr"]["desc"])}\\n\\n{nice_value(port_info["attr"]["inst"])}"')

    else:
        output.append(f'Desc="{nice_value(port_info["attr"]["desc"])}"')

    output.append(f'porter="{oc_join(port_info["attr"]["porter"])}"')
    output.append(f'locat="{file_name}"')

    if port_info["attr"]['rtr']:
        output.append(f'runtype="rtr"')

    if port_info["attr"]['runtime'] == "mono-6.12.0.122-aarch64.squashfs":
        output.append(f'mono="y"')

    output.append(f'genres="{",".join(port_info["attr"]["genres"])}"')

    return ' '.join(output)


def port_info_load(raw_info, source_name=None, do_default=False, port_log=None):
    if port_log is None:
        port_log = []

    if isinstance(raw_info, pathlib.PurePath):
        source_name = str(raw_info)

        with raw_info.open('r') as fh:
            try:
                info = json.load(fh)

            except json.decoder.JSONDecodeError as err:
                port_log.append(f"- Unable to load {source_name}: {err}")
                info = None

            if info is None or not isinstance(info, dict):
                if do_default:
                    info = {}
                else:
                    return None

    elif isinstance(raw_info, str):
        if raw_info.strip().startswith('{') and raw_info.strip().endswith('}'):
            if source_name is None:
                source_name = "<str>"

            try:
                info = json.loads(raw_info)

            except json.decoder.JSONDecodeError as err:
                port_log.append(f"- Unable to load {source_name}: {err}")
                info = None

            if info is None or not isinstance(info, dict):
                if do_default:
                    info = {}
                else:
                    return None

        elif Path(raw_info).is_file():
            source_name = raw_info

            with open(raw_info, 'r') as fh:
                try:
                    info = json.load(fh)

                except json.decoder.JSONDecodeError as err:
                    port_log.append(f"- Unable to load {source_name}: {err}")
                    info = None

                if info is None or not isinstance(info, dict):
                    if do_default:
                        info = {}
                    else:
                        return None

        else:
            if source_name is None:
                source_name = "<str>"

            port_log.append(f'- Unable to load port_info from {source_name!r}: {raw_info!r}')
            if do_default:
                info = {}
            else:
                return None

    elif isinstance(raw_info, dict):
        if source_name is None:
            source_name = "<dict>"

        info = raw_info

    else:
        port_log.append(f'- Unable to load port_info from {source_name!r}: {raw_info!r}')
        if do_default:
            info = {}
        else:
            return None

    if info.get('version', None) == 1 or 'source' in info:
        # Update older json version to the newer one.
        info = info.copy()
        info['name'] = info['source'].rsplit('/', 1)[-1]
        del info['source']
        info['version'] = 2

        if info.get('md5', None) is not None:
            info['status'] = {
                'source': "Unknown",
                'md5': info['md5'],
                'status': "Unknown",
                }
            del info['md5']

        # WHOOPS! :O
        if info.get('attr', {}).get('runtime', None) == "blank":
            info['attr']['runtime'] = None

    if isinstance(info.get('attr', {}).get('porter'), str):
        info['attr']['porter'] = [info['attr']['porter']]

    if isinstance(info.get('attr', {}).get('reqs', None), dict):
        info['attr']['reqs'] = [
            key
            for key in info['attr']['reqs']]

    if isinstance(info.get("version", None), str):
        info["version"] = int(info["version"])

    # This strips out extra stuff
    port_info = {}

    for attr, attr_default in PORT_INFO_ROOT_ATTRS.items():
        if isinstance(attr_default, (dict, list)):
            attr_default = attr_default.copy()

        port_info[attr] = info.get(attr, attr_default)

    for attr, attr_default in PORT_INFO_ATTR_ATTRS.items():
        if isinstance(attr_default, (dict, list)):
            attr_default = attr_default.copy()

        port_info['attr'][attr] = info.get('attr', {}).get(attr, attr_default)

    if port_info['attr']['image'] == None:
        port_info['attr']['image'] = {}

    if isinstance(port_info['items'], list):
        i = 0
        while i < len(port_info['items']):
            item = port_info['items'][i]
            if item.startswith('/'):
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item.startswith('../'):
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if '/../' in item:
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]
                continue

            if item == "":
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items'][i]

            i += 1

    if isinstance(port_info['items_opt'], list):
        i = 0
        while i < len(port_info['items_opt']):
            item = port_info['items_opt'][i]
            if item.startswith('/'):
                port_log.append(f"- port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item.startswith('../'):
                port_log.append(f"- port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if '/../' in item:
                port_log.append(f"- port_info['items_opt'] contains bad name {item}")
                del port_info['items_opt'][i]
                continue

            if item == "":
                port_log.append(f"- port_info['items'] contains bad name {item!r}")
                del port_info['items_opt'][i]

            i += 1

        if port_info['items_opt'] == []:
            port_info['items_opt'] = None

    if isinstance(port_info['attr'].get('genres', None), list):
        genres = port_info['attr']['genres']
        port_info['attr']['genres'] = []

        for genre in genres:
            if genre.casefold() in PORT_INFO_GENRES:
                port_info['attr']['genres'].append(genre.casefold())

    if port_info['attr']['image'] == None:
        port_info['attr']['image'] = {}

    if port_info['attr']['runtime'] == "blank":
        port_info['attr']['runtime'] = None

    if port_info['attr']['rtr'] is not False and port_info['attr']['inst'] in ("", None):
        port_info['attr']['inst'] = "Ready to run."

    return port_info


def port_info_merge(port_info, other):
    if isinstance(other, (str, pathlib.PurePath)):
        other_info = port_info_load(other)

    elif isinstance(other, dict):
        other_info = other

    else:
        print(f"# Unable to merge {other!r}")
        return None

    for attr, attr_default in PORT_INFO_ROOT_ATTRS.items():
        if attr == 'attr':
            break

        value_a = port_info[attr]
        value_b = other_info[attr]

        if value_a is None or value_a == "" or value_a == []:
            port_info[attr] = value_b
            continue

        if value_b in (True, False) and value_a in (True, False, None):
            port_info[attr] = value_b
            continue

        if isinstance(value_b, str) and value_a in ("", None):
            port_info[attr] = value_b
            continue

        if isinstance(value_b, list) and value_a in ([], None):
            port_info[attr] = value_b[:]
            continue

        if isinstance(value_b, dict) and value_a in ({}, None):
            port_info[attr] = value_b.copy()
            continue

    for key_b, value_b in other_info['attr'].items():
        if key_b not in port_info['attr']:
            continue

        if value_b in (True, False) and port_info['attr'][key_b] in (True, False, None):
            port_info['attr'][key_b] = value_b
            continue

        if isinstance(value_b, str) and port_info['attr'][key_b] in ("", None):
            port_info['attr'][key_b] = value_b
            continue

        if isinstance(value_b, list) and port_info['attr'][key_b] in ([], None):
            port_info['attr'][key_b] = value_b[:]
            continue

        if isinstance(value_b, dict) and port_info['attr'][key_b] in ({}, None):
            port_info['attr'][key_b] = value_b.copy()
            continue

    if port_info['attr']['image'] == None:
        port_info['attr']['image'] = {}

    if port_info['attr']['runtime'] == "blank":
        port_info['attr']['runtime'] = None

    return port_info


def check_port(port_name, zip_file, extra_data=None):
    if extra_data is None:
        extra_data = {
            }

    extra_data.setdefault('errors', [])
    extra_data.setdefault('warnings', [])
    extra_data['port_info_file'] = None
    extra_data['no_port_json'] = None

    items = []
    scripts = []
    dirs = []

    port_info_file = None

    with zipfile.ZipFile(zip_file, 'r') as zf:
        for file_info in zf.infolist():
            if file_info.filename.startswith('/'):
                ## Sneaky
                extra_data['errors'].append(f"- Port {port_name} has an illegal file {file_info.filename!r}, aborting.")
                return None

            if file_info.filename.startswith('../'):
                ## Little
                extra_data['errors'].append(f"- Port {port_name} has an illegal file {file_info.filename!r}, aborting installation.")
                return None

            if '/../' in file_info.filename:
                ## Shits
                extra_data['errors'].append(f"- Port {port_name} has an illegal file {file_info.filename!r}, aborting.")
                return None

            if '/' in file_info.filename:
                parts = file_info.filename.split('/')

                if parts[0] not in dirs:
                    items.append(parts[0] + '/')
                    dirs.append(parts[0])

                if len(parts) == 2:
                    if parts[1].lower().endswith('.port.json'):
                        ## TODO: add the ability for multiple port folders to have multiple port.json files. ?
                        if port_info_file is not None:
                            extra_data['warnings'].append((
                                f"- Port {port_name} has multiple port.json files.\n"
                                f"  - Before: {port_info_file!r}\n"
                                f"  - Now:    {file_info.filename!r}"))

                        port_info_file = file_info.filename

                if file_info.filename.lower().endswith('.sh'):
                    extra_data['warnings'].append(f"- Port {port_name} has {file_info.filename} inside, this can cause issues.")

            else:
                if file_info.filename.lower().endswith('.sh'):
                    scripts.append(file_info.filename)
                    items.append(file_info.filename)
                else:
                    extra_data['warnings'].append(f"- Port {port_name} contains {file_info.filename} at the top level, but it is not a shell script.")

        if len(dirs) == 0:
            extra_data['errors'].append(f"- Port {port_name} has no directories, aborting.")
            return None

        if len(scripts) == 0:
            extra_data['errors'].append(f"- Port {port_name} has no scripts, aborting.")
            return None

        if port_info_file is not None:
            extra_data['port_info_file'] = port_info_file

            port_info = port_info_load(
                zf.read(port_info_file).decode('utf-8'),
                source_name=f"{str(zip_file)}/{port_info_file}",
                port_log=extra_data['errors'],
                )

            extra_data['no_port_json'] = port_info is None
            if port_info is None:
                return None

        else:
            port_info_data = None
            port_info_file = f"{dirs[0]}/{(name_cleaner(port_name.rsplit('.', 1)[0]) + '.port.json')}"

            extra_data['port_info_file'] = port_info_file
            extra_data['no_port_json'] = True
            extra_data['errors'].append(f"- No port info file found, recommended name is {port_info_file}")

            return None

    ## These two are always overriden.
    port_info['name'] = name_cleaner(port_name)
    port_info['items'] = items

    return port_info


def extract_port_json(zip_file, ports_info, extra_data):
    port_name = name_cleaner(zip_file.name)

    port_info = check_port(port_name, zip_file, extra_data)

    if port_info is None:
        return

    if "status" in port_info:
        del port_info["status"]

    if "files" in port_info:
        del port_info["files"]

    ports_info[port_name] = port_info


def port_info(file_name, ports_json, ports_status, extra_data):
    clean_name = name_cleaner(file_name.name)

    file_md5 = hash_file(file_name)

    default_status = {
        'md5': file_md5,
        'date_added': TODAY,
        'date_updated': TODAY,
        }

    with open(file_name.name + '.md5', 'wt') as fh:
        fh.write(file_md5)

    if clean_name not in ports_status:
        ports_status[clean_name] = default_status
        extra_data["status"] = "new"

    elif ports_status[clean_name]['md5'] is None:
        ports_status[clean_name]['md5'] = file_md5
        extra_data["status"] = "updated"

    elif ports_status[clean_name]['md5'] != file_md5:
        ports_status[clean_name]['md5'] = file_md5
        ports_status[clean_name]['date_updated'] = TODAY
        extra_data["status"] = "updated"

    else:
        extra_data["status"] = "unchanged"

    if clean_name in ports_json:
        ports_json[clean_name].update(ports_status[clean_name])

        ports_json[clean_name]['download_size'] = file_name.stat().st_size
        ports_json[clean_name]['download_url'] = BASE_RELEASE_URL + (file_name.name.replace(" ", ".").replace("..", "."))


def util_info(file_name, util_json):
    clean_name = name_cleaner(file_name.name)

    file_md5 = hash_file(file_name)

    with open(file_name.name + '.md5', 'wt') as fh:
        fh.write(file_md5)

    if file_name.name.lower().endswith('.squashfs'):
        name = runtime_nicename(file_name.name)

    else:
        name = file_name.name

    util_json[clean_name] = {
        "name": name,
        'md5': file_md5,
        'download_size': file_name.stat().st_size,
        'download_url': BASE_RELEASE_URL + (file_name.name.replace(" ", ".").replace("..", ".")),
        }


def joiner(*items):
    for item in items:
        yield from item


def main(args):
    portmaster_path = Path('.')
    portmaster_images_path = Path('images')

    # (BASE_RELEASE_URL +  "ports_status.json")
    ports_status_file = Path('.') / "ports_status.json"

    ports_json_file = Path('.') / "ports.json"
    status = {
        "new": 0,
        "unchanged": 0,
        "updated": 0,
        "total": 0,
        }

    extra_info = {}
    ports_json = {}
    images_json = {}
    util_json = {}
    file_names = {}
    all_ports = []

    ports_status = {}

    if ports_status_file.is_file():
        with ports_status_file.open('r') as fh:
            ports_status = json.load(fh)

    else:
        ports_status = fetch_json(BASE_RELEASE_URL + "ports_status.json")
        if ports_status is None:
            ports_status = {}

    ## Okay find images for ports.
    for file_name in portmaster_images_path.glob('*'):
        if file_name.suffix.lower() not in ('.jpg', '.png'):
            continue

        image_name = name_cleaner(file_name.name)
        if image_name.count('.') < 2:
            continue

        port_name, image_type, suffix = image_name.rsplit('.', 2)
        port_name += '.zip'

        if port_name not in images_json:
            images_json[port_name] = {
                "screenshot": None,
                "cover": None,
                "thumbnail": None,
                "video": None,
                }

        if image_type not in PORT_IMAGES:
            continue

        images_json[port_name][image_type] = file_name.name

    for file_name in joiner(
            portmaster_path.glob('*.zip'),
            portmaster_path.glob('*.squashfs'),
            ):

        if file_name.name.lower().endswith('.squashfs') or file_name.name.lower() in ("portmaster.zip", "images.zip", "ports.md"):
            util_info(file_name, util_json)
            continue

        # ZZzzzz
        if file_name.name == 'RVGL.zip':
            continue

        port_name = name_cleaner(file_name.name)
        extra_info[port_name] = extra_data = {}
        file_names[port_name] = file_name.name.replace(" ", ".").replace("..", ".")

        if port_name not in all_ports:
            all_ports.append(port_name)

        extract_port_json(file_name, ports_json, extra_data)
        port_info(file_name, ports_json, ports_status, extra_data)

        if port_name not in ports_json:
            continue

        if port_name not in images_json:
            extra_info[port_name]['errors'].append("- No port images found.")

        else:
            for image_type in PORT_IMAGES_REQ:
                if images_json[port_name].get(image_type, None) is None:
                    extra_info[port_name]['errors'].append(f"- Missing image {image_type}.")

            ports_json[port_name]['attr']['image'] = images_json[port_name]

    if '--do-check' in args:
        warnings = False
        errors = False
        for port_name in sorted(all_ports, key=lambda port_name: port_name.lower()):
            if extra_info[port_name].get('status', None) == "unchanged" and not extra_info[port_name].get('no_port_json', False):
                continue

            if len(extra_info[port_name]['errors']) > 0 or len(extra_info[port_name]['warnings']) > 0:
                print(f"Bad port {port_name}")
                # print(f"- Debug: {extra_info[port_name]}")

                if len(extra_info[port_name]['errors']):
                    print("- Errors:")
                    print("  " + f"\n  ".join(extra_info[port_name]['errors']) + "\n")
                    errors = True

                if len(extra_info[port_name]['warnings']):
                    print("- Warnings:")
                    print("  " + f"\n  ".join(extra_info[port_name]['warnings']) + "\n")
                    warnings = True

        if errors:
            return 255

        elif warnings:
            return 127

        return 0

    ports_json_output = {
        "ports": {},
        "utils": {},
        }

    with open("ports.md", "w") as fh:
        for port_name in sorted(ports_json.keys(), key=lambda port_name: ports_json[port_name]['attr']['title'].lower()):
            extra_data = extra_info[port_name]
            status['total'] += 1
            status[extra_data['status']] += 1

            if len(extra_data['errors']) > 0 or len(extra_data['warnings']) > 0:
                print(f"Bad port {port_name}")

                if len(extra_data['errors']):
                    print("- Errors:")
                    print("  " + f"\n  ".join(extra_data['errors']) + "\n")

                if len(extra_data['warnings']):
                    print("- Warnings:")
                    print("  " + f"\n  ".join(extra_data['warnings']) + "\n")

            ports_json_output['ports'][port_name] = ports_json[port_name]

            print(port_info_to_portmd(ports_json[port_name], file_names[port_name]), file=fh)
            print("", file=fh)

    for util_name in sorted(util_json.keys(), key=lambda util_name: util_name.lower()):
        ports_json_output['utils'][util_name] = util_json[util_name]

    with ports_json_file.open('w') as fh:
        json.dump(ports_json_output, fh, indent=4)

    with ports_status_file.open('w') as fh:
        json.dump(ports_status, fh, indent=4, sort_keys=True)

    print(f"Changes:")
    print(f"  New:       {status['new']}")
    print(f"  Updated:   {status['updated']}")
    print(f"  Unchanged: {status['unchanged']}")
    print("")
    print(f"Total Ports: {status['total']}")


if __name__ == '__main__':
    exit(main(sys.argv))
