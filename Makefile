
.if !defined(VERSION)
VERSION=0.3
.endif

IMAGE=mirrorclock-standalone

USER != whoami
AWSOPTS=
.if defined(AWSPROFILE)
AWSOPTS+="--profile $(AWSPROFILE)"
.endif
# can be also set from ~/.aws/config, so it's optional
.if defined(AWSREGION)
AWSOPTS+="--region $(AWSREGION)"
.else
AWSREGION != aws $(AWSOPTS) configure get region
.endif
AWSACCOUNTID != aws $(AWSOPTS) sts get-caller-identity --query "Account" --output text

# and we add the target for the upload
EXTRADEPS += ecr-login

# and ensure the repo exists
.if !defined(REPONAME)
# if no REPONAME specified, default to IMAGE
REPONAME=$(IMAGE)
.endif
AWSREPONAME != aws ecr describe-repositories --repository-names $(REPONAME) --output text 2>/dev/null
.if AWSREPONAME==""
.error "Repository REPONAME does not exist"
.endif

# and set the AWS registry's name
AWSREGNAME=$(AWSACCOUNTID).dkr.ecr.$(AWSREGION).amazonaws.com

.PHONY: build ecr-login push

foobar:
	@echo "Docker user: $(USER)"

ecr-login!
	aws $(AWSOPST) ecr get-login-password | docker login --username AWS --password-stdin \
	$(AWSREGNAME) 2> /dev/null

build:
	docker build --tag $(USER)/$(IMAGE):$(VERSION) \
	--build-arg VERSION=$(VERSION) mirrorclock-standalone/

push: $(EXTRADEPS) build
	docker tag $(USER)/$(IMAGE):$(VERSION) $(AWSREGNAME)/$(IMAGE):$(VERSION)
	docker push $(AWSREGNAME)/$(IMAGE):$(VERSION)
