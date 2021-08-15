run: build
	docker run -it --rm -v $(PWD)/diagrams:/app/diagrams jlob0/uml-inaction diagrams/default.puml

build:
	docker build --tag jlob0/uml-inaction .

sh: build
	docker run -it --rm --entrypoint bash -v $(PWD)/diagrams:/app/diagrams jlob0/uml-inaction
