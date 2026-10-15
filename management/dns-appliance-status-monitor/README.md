# DNS Appliance Status Monitor

세 DNS 장비가 설치 후 실제로 응답하는지 한 화면에서 확인하는 한국어 상태판이다.
외부 패키지, 계정, 클라우드 연결이 필요 없으며 대상 장비에는 어떤 변경도 하지 않는다.

Pop!_OS 또는 Python 3가 있는 Linux에서 실행한다.

```sh
./start
```

브라우저에서 <http://127.0.0.1:8080>을 연다. 각 노드의 DNS UDP/TCP 질의와
Cockpit `9090`, Technitium 관리 `53443`, node exporter `9100` 연결을 10초마다
확인한다. 기본적으로 localhost에만 열리므로 다른 장비에 공개되지 않는다.

주소나 확인용 DNS 이름이 바뀌면 `config.json`을 수정한다. LAN에 상태판을
공개하려면 위험을 이해한 뒤 `./start --listen 10.0.0.X`처럼 관리 장비 주소를
명시한다. 방화벽 및 접근 통제는 별도로 구성해야 한다.
