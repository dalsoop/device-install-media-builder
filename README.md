# Device Install Media Builder

[![CI](https://github.com/dalsoop/device-install-media-builder/actions/workflows/ci.yml/badge.svg)](https://github.com/dalsoop/device-install-media-builder/actions/workflows/ci.yml)

원하는 운영체제와 복구 도구를 골라 하나의 **Device Install USB**로 만드는
포크형 저장소다. 공개 설치 이미지 정보는 별도
[Device Install Media Catalog](https://github.com/dalsoop/device-install-media-catalog)에서
가져오고, 이 저장소는 선택·다운로드·검증·한국어 메뉴·USB 기록과 개인별
자동설치 프로필을 담당한다.

기본 구성에는 Proxmox VE, Proxmox Backup Server, TrueNAS SCALE, Pop!_OS,
Debian Live와 HP DNS 장비용 보호된 자동설치 프로필이 포함된다.

> **현재 보증 범위:** 저장소 계약과 격리 시뮬레이션은 CI에서 검증된다. 실제
> USB, BIOS/UEFI/Secure Boot, 물리 디스크 삭제, 설치 후 부팅은 아직 검증되지
> 않았다. 물리 USB 기록은 별도 대상 확인과 명시적 승인 없이는 수행하지 않는다.

## 내가 사용하는 방법

권장 흐름은 이 저장소를 포크하고 내 포크의 컬렉션과 로컬 프로필만 관리하는
것이다. 공개 카탈로그 개선은 Catalog 저장소에 별도 Pull Request로 보낸다.

```sh
git clone https://github.com/<내계정>/device-install-media-builder.git
cd device-install-media-builder

./device-install-media available
./device-install-media plan
./device-install-media simulate
```

`simulate`는 카탈로그 커밋과 선택 결과를 검증하지만 ISO를 내려받거나 디스크를
지우지 않는다. 실제 다운로드는 Linux 빌더에서 다음처럼 실행한다.

```sh
./device-install-media prepare
```

DNS ISO를 별도로 빌드한 뒤 제거 가능한 USB의 장치 경로와 시리얼을 다시
확인하고 기록한다.

```sh
sudo ./device-install-media write \
  --device /dev/sdX \
  --runtime-artifact dns-appliance=/absolute/path/dns-appliance.iso \
  --runtime-manifest dns-appliance=/absolute/path/build-manifest.json \
  --confirm 'ERASE /dev/sdX USB_SERIAL'
```

이 명령은 선택한 USB의 기존 파티션과 데이터를 모두 지운다. 16GB 장치는
지원하지 않는다. 기본 구성은 최소 32GB, 권장 64GB다.

## 무엇을 담을지 바꾸기

사람이 읽는 명령으로 공개 카탈로그 항목을 확인하고 선택할 수 있다.

```sh
./device-install-media available
./device-install-media exclude pop-os
./device-install-media include pop-os
./device-install-media plan
```

이 명령은 [`collections/device-install.json`](collections/device-install.json)의
`entries` 목록만 바꾼다. 직접 JSON을 편집해도 된다. 개인 ISO나 조직 전용
자동설치 프로필은 `usb-media/local-entries/`에 두고
[`usb-media/composition.json`](usb-media/composition.json)의 `local_entries`에
등록한다.

공개 Catalog의 다른 포크를 쓰려면 `composition.json`의 저장소와 40자리 커밋을
함께 바꾼다. Builder는 브랜치 이름이나 `latest`를 받지 않고 정확한 커밋만
가져온다.

## 저장소 두 개의 역할

```text
device-install-media-catalog
  공개 OS/도구 JSON + 공식 URL + SHA-256
                    │ 고정된 커밋
                    ▼
device-install-media-builder 포크
  collection + local profile + bundles
                    │ resolve / verify / fetch
                    ▼
              Device Install USB
```

| 저장소/경로 | 책임 |
| --- | --- |
| `device-install-media-catalog` | 공개 부트로더와 OS 메타데이터 |
| `usb-media/composition.json` | 카탈로그 커밋, USB 속성, 로컬 항목과 번들 |
| `collections/device-install.json` | 이번 USB에 담을 공개 항목 |
| `usb-media/local-entries/` | 내 포크만의 런타임 이미지와 설치 프로필 |
| `usb-media/resolve-catalog` | 외부 Catalog와 로컬 선택을 검증된 계획으로 합성 |
| `usb-media/fetch-images` | `locked-download` 이미지를 받아 SHA-256 검증 |
| `usb-media/write-usb-linux` | 확인된 제거식 디스크에 Ventoy와 이미지를 기록 |
| `installer/` | 기본 DNS 프로필의 오프라인 ISO와 파괴 방지 게이트 |
| `management/` | DNS 클러스터 초기화, Tailscale, 백업, 상태판 |

## 기본 USB에 포함되는 항목

| 영역 | 항목 | 실행 방식 | 공급 방식 |
| --- | --- | --- | --- |
| DNS | Debian 13 + Technitium DNS | 장비 일치 후 자동 | 로컬 `runtime-artifact` |
| 가상화 | Proxmox VE | 대화형 설치 | Catalog `locked-download` |
| 백업 | Proxmox Backup Server | 대화형 설치 | Catalog `locked-download` |
| 스토리지 | TrueNAS SCALE | 대화형 설치 | Catalog `locked-download` |
| 데스크톱 | Pop!_OS 24.04 | 대화형·한국어 선택 | Catalog `locked-download` |
| 점검 | Debian Live | 라이브 환경 | Catalog `locked-download` |
| 검증 | DNS 장비 상태판 | 읽기 전용 웹 화면 | Builder 번들 |

Ventoy 메뉴는 한국어가 기본이며 `L` 키로 언어를 바꿀 수 있다. 자동 선택
타이머는 없다. 범용 설치기는 모두 대화형이고 DNS 자동 설치만 별도의 파괴
방지 프로필을 사용한다.

## DNS 기본 프로필

| 역할 | 주소 | 책임 |
| --- | --- | --- |
| 공유기 | `10.0.0.1` | 게이트웨이·DHCP 권한 |
| `dns01` | `10.0.5.1/16` | 기본 클러스터 노드 |
| `dns02` | `10.0.5.2/16` | 보조 클러스터 노드 |
| `dns03` | `10.0.5.3/16` | 보조 클러스터 노드 |

세 노드는 Debian 13, Technitium DNS Server, OpenSSH, Cockpit, Tailscale
클라이언트를 사용한다. 설치 자체는 인터넷 없이 완료되어야 하며 Tailscale은
나중에 관리 호스트가 일회용 키로 등록한다. 실제 HP 제품 ID, 시리얼/UUID,
NIC MAC, 내부 디스크가 로컬 인벤토리와 모두 일치하지 않으면 삭제 전에 멈춘다.

저장소에는 ISO, 비밀번호, 토큰, 개인키, 실제 장비 인벤토리, 복구 아카이브를
커밋하지 않는다. `overlays`나 Git 추적 파일에 비밀값을 복사하지 말고 로컬 입력
또는 Actions Secrets로만 주입한다.

다음 문서부터 읽으면 된다: [USB 사용법](usb-media/README.md),
[아키텍처](docs/architecture.md), [보안](docs/security.md),
[OS 설치](docs/os-install.md), [검증 게이트](docs/verification.md).
