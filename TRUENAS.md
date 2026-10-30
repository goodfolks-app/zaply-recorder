# Zaply Recorder on TrueNAS SCALE

Install it, connect it to Zaply, update it: about 10 minutes. On a NAS, Zaply
Recorder runs as a TrueNAS app, always on, with the recordings in a dataset you
can share with your computers. Other systems:
[the download page](https://goodfolks-app.github.io/zaply-recorder/).

**What you need**

- TrueNAS SCALE **24.10 (Electric Eel) or later**, where apps run on Docker.
- The NAS on the same network as your iPhone, iPad or Apple TV.
- Zaply on an iPhone or iPad, signed in as the household's owner: the owner
  sets the recorder up.

In the examples, `tank` is the pool and `tank/media` the dataset shared with
your computers. Use your own names: the paths follow them.

## 1. Make a dataset for the recordings

Recordings and downloads go in a dataset of their own, so you can open them
from your computers and keep them if you ever remove the app. The recorder's
settings need no dataset: TrueNAS makes one by itself in step 2.

1. Open **Datasets** and select the dataset to put it in, for example
   `tank/media`, one you share with your computers.
2. Click **Add Dataset**.
3. Fill it in:

   | Field | Value |
   |---|---|
   | Parent Path | `tank/media` (already filled in) |
   | Name | `Zaply` |
   | Dataset Preset | **SMB** if the parent is shared over SMB, so recordings can be opened and deleted from a Mac or PC. Otherwise **Generic**. |

4. Click **Save**. Its path on the NAS is `/mnt/tank/media/Zaply`: `/mnt/`
   followed by the dataset's full name. Select the dataset to see it in its
   details.

## 2. Install the app

Open **Apps ▸ Discover Apps** and click **Custom App** at the top right. Fill
in only these fields; leave every other one as it is.

| Section | Field | Value |
|---|---|---|
| At the top | Application Name | `zaply-recorder` |
| Image Configuration | Repository | `ghcr.io/goodfolks-app/zaply-recorder` |
| | Tag | `latest` |
| Container Configuration | Timezone | Your own, picked in the list |
| | Restart Policy | Unless Stopped |
| Network Configuration | Host Network | **Ticked**: Zaply then finds the recorder by itself |

**Storage Configuration: two entries.** Click **Add** next to Storage once for
each.

| Field | Entry 1: its settings | Entry 2: the recordings |
|---|---|---|
| Type | **ixVolume** (Dataset created automatically by the system) | **Host Path** (Path that already exists on the system) |
| Read Only | unticked | unticked |
| Mount Path | `/data` | `/library` |
| Enable ACL | unticked | unticked |
| Dataset Name | `data` (replace `storage_entry`) | |
| Host Path | | `/mnt/tank/media/Zaply`, picked in the list |

> [!WARNING]
> **Mount Path and Host Path are not the same thing.** The Mount Path is the
> folder as the recorder sees it, always `/data` or `/library`. The Host Path
> is the folder on the NAS, starting with `/mnt/`. A `/mnt/…` path in Mount
> Path is the usual mistake.

Click **Install**. Within a minute, **Apps ▸ Installed** shows
**zaply-recorder** as **Running**.

## 3. Open its page and set a password

1. In a browser, open `http://<the NAS's address>:9393`: the address of
   TrueNAS's own page, with `:9393` at the end. For example
   `http://192.168.1.20:9393`.
2. Go to **Settings**. Give it a **Name**, for example *NAS* (otherwise it's
   named after the NAS), and a **Password**. Click **Save and restart**: it's
   back within a few seconds.

The library folder shows `/library` and can't be changed there: TrueNAS sets
it, through the storage in step 2.

> [!TIP]
> On a Mac, Chrome says *This site can't be reached* (`ERR_ADDRESS_UNREACHABLE`)
> until it may reach your network: **System Settings ▸ Privacy & Security ▸
> Local Network**, turn on Google Chrome, then quit and reopen it. Safari needs
> nothing.

## 4. Add it in Zaply

On an iPhone or iPad, as the household's owner:

1. Open **Settings ▸ Zaply Recorder**.
2. If another recorder is set up, the Mac app for example, scroll down and tap
   **Remove the recorder** first.
3. Tap **Set up your recorder**, pick the NAS by its name, and type its
   password.

Everyone in the household then sees it on their own devices, Apple TV
included. To record, use **Record** on a channel or in the TV guide, **Record
every airing**, or **Record the match**. For a film or an episode, use
**Download to the recorder**.

> [!TIP]
> **The NAS isn't listed?** Check that Host Network is ticked (Apps ▸ Installed
> ▸ zaply-recorder ▸ Edit). You can also type its address in the set-up sheet:
> `http://<the NAS's address>:9393`.

## 5. Away from home (optional)

At home, Zaply talks to the recorder directly. To schedule and watch from
elsewhere, choose one way:

- **Tailscale** (recommended): run Tailscale on the NAS (TrueNAS has a
  Tailscale app in Discover Apps) and on your iPhone. In Zaply, **Settings ▸
  Zaply Recorder ▸ Address away from home**:
  `http://<the NAS's Tailscale address>:9393`. Nothing is exposed to the
  internet.
- **Port forwarding**: on your router, forward port **9394** to the NAS, and
  only that one, never 9393. In Zaply, set Address away from home to
  `https://<your home's public address>:9394`. Open Zaply once at home first,
  so it learns the recorder's certificate.

## 6. Update

Zaply Recorder looks for a new version twice a day. When there is one, its
page (`http://<the NAS's address>:9393`) and Zaply's **Settings ▸ Zaply
Recorder** say so. Version 1.0.0 doesn't look: if yours says 1.0.0, update it
once as below.

To update:

1. **Apps ▸ Installed**: select zaply-recorder and click **Edit**.
2. In Image Configuration, set **Pull Policy** to **Always pull** and click
   **Save**. TrueNAS downloads the new version and starts the app again with
   it.
3. Once it is running, click **Edit** again, set the Pull Policy back to its
   default, and **Save**, so the app also starts when the NAS has no internet.

Don't wait for TrueNAS to show **Update available**: for an app that follows
`latest`, it shows late, or not at all. When it does show, its **Update**
button works too.

Either way, the settings and recordings stay, and a recording in progress
resumes in the same file.

## 7. Where things are

| What | Where |
|---|---|
| Recordings | The `Zaply` dataset: `Live TV`, `Movies` and `Series` folders, one file per recording. Plex, Jellyfin and Emby can read them as they are. |
| Its settings | The ixVolume TrueNAS made (`data`). |
| Its page | `http://<the NAS's address>:9393`: what's recording, the schedule, the library, the logs, the settings. |
| Its log | On its page, under **Logs**, or in TrueNAS: Apps ▸ Installed ▸ zaply-recorder ▸ Workloads ▸ the logs icon. |
| Ports | **9393**: its page and the Zaply apps. **9394**: HTTPS, only for a port forwarded from the internet. Both must be free on the NAS. |

## 8. If something goes wrong

| What you see | What to do |
|---|---|
| Install refuses the Host Path | The `Zaply` dataset must exist (step 1), and the Host Path must start with `/mnt/`. You can make the dataset from the path list: select its parent, then **Create Dataset**. |
| The app doesn't reach Running | Open its log (Apps ▸ Installed ▸ zaply-recorder ▸ Workloads ▸ logs icon): it says why. |
| Its page doesn't open | Check the address ends with `:9393` and starts with `http://`, not https. In Chrome on a Mac, see the tip in step 3. |
| Zaply doesn't find it | Host Network must be ticked. Otherwise type its address in the set-up sheet. |
| Recordings can't be deleted from a Mac or PC | The dataset needs the SMB preset (step 1), or permissions that let your user change files written by the app. |

**Removing it:** Apps ▸ Installed ▸ zaply-recorder ▸ **Delete**. With **Remove
ixVolumes** ticked, its settings and list of recordings go too. The recordings
themselves stay in the `Zaply` dataset.

---

Help: the [Zaply Discord](https://discord.gg/JZhBVAD5V6), or
[goodfolks.fr/zaply/support](https://goodfolks.fr/zaply/support).
