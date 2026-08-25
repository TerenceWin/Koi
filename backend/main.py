from fastapi import FastAPI, Request, status

app = FastAPI()


@app.get("/")
def home(request: Request):
    return {"status": "ok"}

@app.get("/registor")
def registorPage(request: Request):
    return {"registorPage": "ok"}

@app.get("/signin")
def signInPage(request: Request):
    return {"signInPage": "ok"}

#HeartBeat
@app.get("/health")
def checkHealth():
    #run health check logic
    return {"status": "Healthy"}

#admin?