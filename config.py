import os

broker_url = os.environ.get('CELERY_BROKER_URL')
celery_result_backend = os.environ.get('CELERY_RESULT_BACKEND')
