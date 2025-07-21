import os
import mlflow
import requests

def main():
    print("Hello from converted notebook")

    print("----------------------------")
    print(os.getenv("MLFLOW_AUTH_HEADER"))
    print(os.getenv("MLFLOW_TRACKING_URI"))
    print("----------------------------")

    # 인증용 requests 세션 생성
    session = requests.Session()
    session.headers.update({
        "Authorization": os.getenv("MLFLOW_AUTH_HEADER")  # ex: Basic dXNlcjpZZ2JXTHV0TTYwRWg=
    })

    resp = requests.get(
        f"{os.getenv('MLFLOW_TRACKING_URI')}/api/2.0/mlflow/experiments/list",
        headers={"Authorization": os.getenv("MLFLOW_AUTH_HEADER")}
    )
    print(resp.status_code, resp.text)

    # 세션을 MLflow에 주입 (비공식 방식이지만 현재까지 가장 안정적)
    import mlflow.tracking
    mlflow.tracking._tracking_service.utils._get_http_session = lambda: session

    # MLflow 서버 설정
    mlflow.set_tracking_uri(os.getenv("MLFLOW_TRACKING_URI"))

    # 실험 이름 설정 (삭제된 이름이면 에러 발생하므로 주의)
    mlflow.set_experiment("Check localhost connection2")

    # 첫 run
    with mlflow.start_run():
        mlflow.log_metric("test", 1)
        mlflow.log_metric("Krish", 2)

    # 두 번째 run
    with mlflow.start_run():
        mlflow.log_metric("test1", 1)
        mlflow.log_metric("Krish1", 2)

    # 세 번째 run
    with mlflow.start_run():
        mlflow.log_metric("test2", 1)
        mlflow.log_metric("Krish2", 2)

if __name__ == "__main__":
    main()
