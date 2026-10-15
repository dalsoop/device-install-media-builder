# Device Install USB

Ventoy 기반의 한국어 우선 멀티부트 USB다. 외부 Catalog의 공개 항목과 Builder
포크의 로컬 항목을 하나의 검증된 계획으로 합성한 뒤 다운로드하고 기록한다.

## 사람이 사용하는 흐름

```sh
# 1. 무엇을 고를 수 있는지 본다.
./device-install-media available

# 2. 담거나 뺀다.
./device-install-media include pop-os
./device-install-media exclude pop-os

# 3. 디스크를 건드리지 않고 결과를 본다.
./device-install-media simulate

# 4. 선택한 외부 이미지를 내려받고 SHA-256을 확인한다.
./device-install-media prepare

# 5. 마지막에만 USB를 기록한다.
sudo ./device-install-media write --device /dev/sdX ...
```

`available`, `plan`, `simulate`는 물리 디스크를 쓰지 않는다. `prepare`는 무시된
캐시 디렉터리에 파일을 내려받는다. 오직 `write`만 대상 USB를 지운다.

## 입력 계층

| 입력 | 역할 |
| --- | --- |
| `composition.json` | 외부 Catalog URL·커밋, USB 이름, 로컬 항목, 번들 |
| `../collections/device-install.json` | 선택한 공개 항목과 메뉴 그룹 |
| `local-entries/*.json` | DNS처럼 이 Builder 포크가 소유하는 항목 |
| 외부 Catalog | 공개 OS·라이브 도구·부트로더 메타데이터 |

`resolve-catalog`는 Catalog의 40자리 커밋을 가져오지만 그 저장소의 스크립트를
실행하지 않는다. JSON 경로와 계약을 Builder가 다시 검증하고
`work/device-install-media/catalog.json`을 만든다. 이 생성 파일이 fetch, 메뉴,
USB 기록 단계의 공통 입력이다.

## 카탈로그 계약

모든 부팅 항목은 다음 공통 필드를 가진다.

| 필드 | 의미 |
| --- | --- |
| `id` | 변경되지 않는 항목 식별자 |
| `group` | Ventoy 메뉴 그룹 |
| `destination` | USB 내부 ISO 경로 |
| `menu_alias` | 한국어 우선 메뉴 이름 |
| `boot_behavior` | `guarded-unattended`, `interactive-installer`, `live-environment` |
| `profile_adapter` | 제품별 추가 동작; 기본값은 `none` |
| `source.kind` | 소스를 해결하는 전략 |

지원하는 소스 전략은 다음과 같다.

| `source.kind` | fetch | verify | stage |
| --- | --- | --- | --- |
| `locked-download` | HTTPS URL | Catalog SHA-256 | 캐시 파일 복사 |
| `runtime-artifact` | 호출자가 경로 제공 | 빌드 매니페스트 digest | 검증된 산출물 복사 |
| `repository-file` | 필요 없음 | Builder 계약 | 단일 파일 번들 |
| `repository-tree` | 필요 없음 | Builder 계약 | 도구 디렉터리 번들 |

공개 `locked-download` 항목은
[Device Install Media Catalog](https://github.com/dalsoop/device-install-media-catalog)에
추가한다. 조직·장비 전용 항목은 내 Builder 포크의 `local-entries/`에 둔다. 새
`source.kind`를 추가하려면 fetch·verify·stage와 거부 시뮬레이션을 함께 구현해야
한다.

## 안전 경계

- USB 메뉴에는 자동 부팅 타이머가 없다.
- Proxmox VE/PBS, TrueNAS, Pop!_OS는 항상 대화형이다.
- DNS ISO만 `guarded-unattended`이며 정확한 HP 인벤토리와 재설치 승인이
  일치해야 내부 디스크를 지울 수 있다.
- USB 기록기는 제거 가능 장치, 읽을 수 있는 시리얼, 루트 디스크가 아님,
  충분한 용량, 정확한 `ERASE <device> <serial>` 문구를 모두 요구한다.
- ISO와 생성 디스크는 Git에 넣지 않는다. USB에는 해석된 카탈로그와 모든 ISO
  체크섬을 함께 기록한다.
- DNS 로컬 항목을 제거하면 `composition.json`의
  `enrollment_reserve_mib`도 `0`으로 바꿔야 한다.

## USB 결과 구조

```text
DEVICE-INSTALL/
├── images/                  선택한 부팅 ISO
├── guides/POP_OS_KO.md
├── tools/dns-appliance-status-monitor/
├── manifests/
│   ├── media-catalog.json
│   ├── MEDIA-CATALOG.SHA256
│   ├── dns-build-manifest.json
│   └── SHA256SUMS
├── ventoy/ventoy.json
├── README_KO.txt
└── README_EN.txt

DNS-ENROLL/                  DNS 프로필을 포함할 때만 생성
├── installer.json
├── records/
└── reinstall/
```

## 필수 검증

- Catalog와 Builder의 GitHub CI가 고정된 정확한 커밋에서 통과
- `tests/media-catalog-simulation.sh`와 전체 Builder CI 통과
- USB의 `MEDIA-CATALOG.SHA256` 및 `SHA256SUMS` 재검증
- 폐기 가능한 VM 디스크에서 모든 대화형 설치기 부팅
- HP 장비에서 BIOS와 UEFI 메뉴, Ventoy 매퍼 제외, USB를 꽂아둔 재부팅 확인
- Pop!_OS 한국어 설치 및 Secure Boot 조건 확인
- 상태판에서 세 노드의 DNS UDP/TCP, Cockpit, Technitium, metrics 확인

소스 시뮬레이션만으로 물리 설치 성공을 보장하지 않는다. 전체 물리 게이트는
[`docs/verification.md`](../docs/verification.md)를 따른다.
