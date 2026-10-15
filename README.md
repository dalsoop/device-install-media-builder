# Homelab Bootstrap Media

[![CI](https://github.com/gujoai/homelab-bootstrap-media/actions/workflows/ci.yml/badge.svg)](https://github.com/gujoai/homelab-bootstrap-media/actions/workflows/ci.yml)

홈랩 장비의 설치·복구·검증을 한 USB에서 수행하기 위한 재현 가능한 소스다.
체크섬이 고정된 범용 설치 이미지와, HP 장비를 정확히 식별한 뒤에만 동작하는
DNS 서버 자동 설치 프로필을 함께 관리한다.

> **현재 보증 범위:** 소스 계약과 격리 시뮬레이션은 CI에서 검증된다. 실제 USB,
> BIOS/UEFI/Secure Boot, 물리 디스크 삭제, 설치 후 부팅은 아직 검증되지 않았다.
> 물리 USB 기록은 별도 대상 확인과 명시적 승인 없이는 수행하지 않는다.

## USB에 포함되는 항목

| 영역 | 항목 | 실행 방식 | 공급 방식 |
| --- | --- | --- | --- |
| DNS | Debian 13 + Technitium DNS | 장비 일치 후 자동 | 로컬 빌드 산출물 |
| 가상화 | Proxmox VE | 대화형 설치 | URL + SHA-256 고정 |
| 백업 | Proxmox Backup Server | 대화형 설치 | URL + SHA-256 고정 |
| 스토리지 | TrueNAS SCALE | 대화형 설치 | URL + SHA-256 고정 |
| 데스크톱 | Pop!_OS 24.04 | 대화형·한국어 선택 | URL + SHA-256 고정 |
| 점검 | Debian Live | 라이브 환경 | URL + SHA-256 고정 |
| 검증 | DNS 장비 상태판 | 읽기 전용 웹 화면 | 저장소 번들 |

Ventoy 메뉴는 한국어가 기본이며 `L` 키로 언어를 바꿀 수 있다. 자동 선택
타이머는 없다. 범용 설치기는 모두 대화형으로 유지되며 DNS 자동 설치만 별도의
파괴 방지 프로필을 사용한다.

## 확장 가능한 구조

[`homelab-usb/catalog.json`](homelab-usb/catalog.json)이 USB 구성의 단일 원장이다.
각 항목은 같은 `entry` 계약을 따르되 `source.kind`에 따라 다른 전략을 사용한다.

```text
catalog entry
├── locked-download   URL과 SHA-256으로 고정된 외부 이미지
└── runtime-artifact  빌드 매니페스트로 검증되는 로컬 산출물

bundle
├── repository-file  안내서 같은 단일 파일
└── repository-tree  상태판 같은 실행 가능한 도구 묶음
```

기존 공급 방식의 OS를 추가할 때는 카탈로그 항목만 추가한다. 새 공급 방식이
필요할 때만 fetch·verify·stage 계약을 구현한다. 제품별 특수 동작은
`profile_adapter`로 격리하므로 DNS의 하드웨어 게이트가 다른 설치기에 전파되지
않고, 범용 설치기의 느슨한 정책도 DNS 프로필을 약화시키지 않는다.

자세한 확장 계약은 [USB 문서](homelab-usb/README.md)와
[결정 기록](docs/decisions/0002-polymorphic-media-catalog.md)에 있다.

## 빠른 시작

Linux 빌더에서 고정된 외부 이미지를 내려받아 검증한다.

```sh
homelab-usb/verify-catalog
homelab-usb/fetch-images
```

DNS ISO를 별도로 빌드한 뒤, 제거 가능한 USB의 장치 경로와 시리얼을 다시
확인하고 기록한다.

```sh
sudo homelab-usb/write-usb-linux \
  --device /dev/sdX \
  --runtime-artifact dns-appliance=/absolute/path/dns-appliance.iso \
  --runtime-manifest dns-appliance=/absolute/path/build-manifest.json \
  --confirm 'ERASE /dev/sdX USB_SERIAL'
```

이 명령은 대상 USB의 기존 파티션과 데이터를 모두 지운다. 16GB 장치는
지원하지 않는다. 최소 32GB, 권장 64GB다.

## DNS 자동 설치 프로필

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

## 저장소 지도

| 경로 | 책임 |
| --- | --- |
| `homelab-usb/` | 미디어 카탈로그, 다운로드, 검증, USB 조립 |
| `installer/` | 오프라인 DNS ISO와 파괴 방지 설치 게이트 |
| `inventory/` | 공개 예제 인벤토리; 실제 장비 값은 무시된 로컬 경로 사용 |
| `management/` | 클러스터 초기화, Tailscale 등록, 백업, 상태판 |
| `zones/` | Git으로 검토되는 DNS 희망 상태 |
| `schemas/` | 등록 기록과 미디어 계약 |
| `tests/` | 설치·관리·카탈로그 격리 시뮬레이션 |
| `docs/` | 구조, 보안, 복구, 네트워크 전환, 검증 게이트 |

저장소에는 ISO, 비밀번호, 토큰, 개인키, 실제 장비 인벤토리, 복구 아카이브를
커밋하지 않는다. 운영 중인 호스트 구성은 `gujoai/infra/host-infra`, 장기
비밀값은 별도 principal secrets store가 소유한다.

다음 문서부터 읽으면 된다: [아키텍처](docs/architecture.md),
[보안](docs/security.md), [OS 설치](docs/os-install.md),
[복구](docs/recovery.md), [검증 게이트](docs/verification.md).
