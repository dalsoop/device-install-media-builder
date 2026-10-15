# Homelab Install & Recovery USB

Ventoy 기반의 한국어 우선 멀티부트 USB다. 설치 이미지 목록, 다운로드 위치,
체크섬, 메뉴, USB 대상 경로와 실행 정책은 모두 [`catalog.json`](catalog.json)에
선언한다. 조립 스크립트는 제품 이름을 직접 알지 않고 카탈로그 계약에 따라
소스를 가져오고, 검증하고, 배치한다.

## 안전 경계

- USB 메뉴에는 자동 부팅 타이머가 없다.
- Proxmox VE/PBS, TrueNAS, Pop!_OS는 항상 대화형이다.
- DNS ISO만 `guarded-unattended`이며 정확한 HP 인벤토리와 재설치 승인이
  일치해야 내부 디스크를 지울 수 있다.
- USB 기록기는 제거 가능 장치, 읽을 수 있는 시리얼, 루트 디스크가 아님,
  충분한 용량, 정확한 `ERASE <device> <serial>` 문구를 모두 요구한다.
- ISO와 생성 디스크는 Git에 넣지 않는다. USB에는 사용한 카탈로그와 모든 ISO
  체크섬을 함께 기록한다.

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
| `locked-download` | HTTPS URL | 카탈로그 SHA-256 | 캐시 파일 복사 |
| `runtime-artifact` | 호출자가 경로 제공 | 빌드 매니페스트 digest | 검증된 산출물 복사 |
| `repository-file` | 필요 없음 | 저장소 계약 | 단일 파일 번들 |
| `repository-tree` | 필요 없음 | 저장소 계약 | 도구 디렉터리 번들 |

`verify-catalog`는 알려지지 않은 전략, 중복 ID/경로, 경로 탈출, HTTP URL,
잘못된 SHA-256, 알려지지 않은 실행 정책과 프로필 어댑터를 거부한다.

## 같은 유형의 OS 추가

일반 ISO는 공통 스크립트를 수정하지 않고 `entries` 배열에
`locked-download` 항목만 추가한다.

```json
{
  "id": "example-live",
  "group": "tools",
  "version": "1.0",
  "destination": "images/90-tools/example-live-1.0.iso",
  "menu_alias": "Example Live 1.0",
  "description_ko": "비파괴 점검용 라이브 환경이다.",
  "description_en": "Live environment for non-destructive inspection.",
  "boot_behavior": "live-environment",
  "profile_adapter": "none",
  "source": {
    "kind": "locked-download",
    "filename": "example-live-1.0.iso",
    "url": "https://downloads.example.test/example-live-1.0.iso",
    "sha256": "<64 lowercase hex characters>"
  }
}
```

새 `source.kind`를 추가할 때는 `fetch-images`, `verify-catalog`,
`write-usb-linux`의 fetch·verify·stage 세 경계를 함께 구현하고 카탈로그
시뮬레이션을 추가해야 한다. 제품별 예외를 일반 항목 분기에 섞지 말고 새
`profile_adapter`로 격리한다.

## 빌드와 기록

Linux에서 카탈로그와 외부 소스를 검증한다.

```sh
usb-media/verify-catalog
usb-media/fetch-images
```

DNS ISO와 빌드 매니페스트를 런타임 항목으로 주입한다.

```sh
sudo usb-media/write-usb-linux \
  --device /dev/sdX \
  --runtime-artifact dns-appliance=/absolute/path/dns-appliance.iso \
  --runtime-manifest dns-appliance=/absolute/path/build-manifest.json \
  --confirm 'ERASE /dev/sdX USB_SERIAL'
```

기존 `--dns-iso`와 `--dns-manifest` 옵션도 호환을 위해 지원하지만 새 자동화는
일반화된 `--runtime-* id=path` 형식을 사용한다.

여섯 외부 이미지, DNS ISO, 2GiB `DNS-ENROLL`, 여유 공간을 합치면 16GB는
부족하다. 32GB가 최소이며 64GB를 권장한다.

## USB 결과 구조

```text
HOMELAB-USB/
├── images/                  카탈로그가 배치한 부팅 ISO
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

DNS-ENROLL/
├── installer.json
├── records/
└── reinstall/
```

## 필수 검증

- `tests/media-catalog-simulation.sh`와 전체 CI 통과
- USB의 `MEDIA-CATALOG.SHA256` 및 `SHA256SUMS` 재검증
- 폐기 가능한 VM 디스크에서 모든 대화형 설치기 부팅
- HP 장비에서 BIOS와 UEFI 메뉴, Ventoy 매퍼 제외, USB를 꽂아둔 재부팅 확인
- Pop!_OS 한국어 설치 및 Secure Boot 조건 확인
- 상태판에서 세 노드의 DNS UDP/TCP, Cockpit, Technitium, metrics 확인

소스 검증만으로 물리 설치 성공을 보장하지 않는다. 전체 물리 게이트는
[`docs/verification.md`](../docs/verification.md)를 따른다.
