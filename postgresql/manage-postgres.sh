#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 로그 함수
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# 필요한 디렉토리 생성
setup_directories() {
    log "디렉토리 설정 중..."
    
    # 데이터 디렉토리
    mkdir -p "C:\Users\lsm\Documents\Java\admin\postgres_data"
    
    # # 초기화 스크립트 디렉토리
    # mkdir -p "C:\Users\lsm\Documents\Java\admin\docker-entrypoint-initdb"
    
    # # 설정 파일이 없는 경우 기본 설정 파일 생성
    # if [ ! -f "C:\Users\lsm\Documents\Java\admin\postgresql.conf" ]; then
    #     warn "postgresql.conf 파일이 없습니다. 기본 설정 파일을 생성합니다."
    #     touch "C:\Users\lsm\Documents\Java\admin\postgresql.conf"
    # fi
}

# 도커 컴포즈 상태 확인
check_status() {
    log "컨테이너 상태 확인 중..."
    docker-compose ps
}

# 도커 컴포즈 시작
start() {
    log "PostgreSQL 컨테이너 시작 중..."
    docker-compose up -d
    if [ $? -eq 0 ]; then
        log "PostgreSQL 컨테이너가 성공적으로 시작되었습니다."
        check_status
    else
        error "PostgreSQL 컨테이너 시작 실패!"
    fi
}

# 도커 컴포즈 중지
stop() {
    log "PostgreSQL 컨테이너 중지 중..."
    docker-compose down
    if [ $? -eq 0 ]; then
        log "PostgreSQL 컨테이너가 성공적으로 중지되었습니다."
    else
        error "PostgreSQL 컨테이너 중지 실패!"
    fi
}

# 로그 보기
show_logs() {
    log "PostgreSQL 컨테이너 로그 표시 중..."
    docker-compose logs -f
}

# 컨테이너 재시작
restart() {
    log "PostgreSQL 컨테이너 재시작 중..."
    docker-compose restart
    if [ $? -eq 0 ]; then
        log "PostgreSQL 컨테이너가 성공적으로 재시작되었습니다."
        check_status
    else
        error "PostgreSQL 컨테이너 재시작 실패!"
    fi
}

# 컨테이너 완전 제거 (볼륨 포함)
clean() {
    warn "모든 컨테이너와 볼륨을 제거합니다. 계속하시겠습니까? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        log "모든 리소스 제거 중..."
        docker-compose down -v
        if [ $? -eq 0 ]; then
            log "모든 리소스가 성공적으로 제거되었습니다."
        else
            error "리소스 제거 실패!"
        fi
    else
        log "작업이 취소되었습니다."
    fi
}

# 사용법 표시
usage() {
    echo "사용법: $0 [command]"
    echo "Commands:"
    echo "  start    - 컨테이너 시작"
    echo "  stop     - 컨테이너 중지"
    echo "  restart  - 컨테이너 재시작"
    echo "  status   - 컨테이너 상태 확인"
    echo "  logs     - 컨테이너 로그 보기"
    echo "  clean    - 모든 리소스 제거 (주의: 데이터 삭제됨)"
    echo "  help     - 이 도움말 표시"
}

# 메인 스크립트
case "$1" in
    start)
        setup_directories
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        check_status
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean
        ;;
    help|*)
        usage
        ;;
esac

exit 0
