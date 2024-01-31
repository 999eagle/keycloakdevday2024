---
title: Automating Keycloak configuration for compliance and agile development
author: Sophie Tauchert
date: '2024-02-22'
institute: Relaxdays GmbH
theme: pureminimalistic
themeoptions: darkmode
lang: en
aspectratio: 169
classoption: notes
header-includes: |
	\setbeameroption{show notes on second screen=right}
	\usepackage[duration=20,notesposition=right]{pdfpc}

	\input{header-logo.tex}
	\AtBeginDocument{\title[Automating Keycloak configuration]{Automating Keycloak configuration for compliance and agile development}}
---

# About me

- IT-Security Engineer at Relaxdays GmbH
- Contributor to Keycloak, NixOS and other open source projects
- Maintaining free, privacy-respecting services like Matrix, Mastodon and TOR

<!--
Configuring identity access management in a heavily microservice-based environment with multiple software development teams can be challenging. Once the configuration grows, it is difficult to keep it consistent and secure when changing it manually. Using the Keycloak admin API allows us to largely automate compliance checks, configuration updates and deployments between staging and production environments. The new OpenAPI spec has been very helpful in developing those automations in Rust, which I present in this talk.
-->

# Our infrastructure

- Heavily microservice-based architecture with Keycloak as SSO
- Keycloak has separate realms for staging and production
- Users and groups are entirely synchronized over LDAP
\pause
- Each microservice has its own Keycloak client with authorization services
- AuthZ is mostly done using LDAP group \rightarrow\ client role \rightarrow\ authz policy \rightarrow\ authz permission
- Configuration is mostly handled by development teams

::: notes
- working on kc introduction at rd since the beginning -> found issues, fixed things
- separate realms -> separate kc endpoints, client secrets, client config etc.
- as of writing this, around 160 separate clients *per realm*

- trust but verify! -> check teams' config for compliance
- allow automated deployments
:::

# Goals

- Check client configuration (protocol mappers, authz, authn flows, etc.) automatically and regularly
- Update clients automatically for new Keycloak versions (`clientId` \rightarrow\ `client_id` claim)
- Compare client configuration between staging/production realms and instances
- Tool using Keycloak's admin API, generated from the OpenAPI spec

::: notes
- tool in rust
- client config for authz is most important yet most lacking in openapi
- default client id mapper previously used clientId claim instead of client_id
- default claim name was switched with (iirc) kc 22 (only for newly created clients)
- some software (notably pulsar) requires one claim for the client id
- -> tool to change claim name in all existing clients' protocol mappers
- client export/import works too but is unwieldy and requires deleting the entire client first
:::

# OpenAPI overview

- Machine-readable API specification in YAML/JSON
- Should contain all API endpoints
  - parameters, status codes, return values, types
- generated automatically and used for frontends like Swagger
- can be used for generating API client code

# OpenAPI spec for Keycloak

- Keycloak generates OpenAPI spec files
- missing or even wrongly documented endpoints
- generated Rust API client code didn't even compile at first
- multiple PRs both to Keycloak for a better OpenAPI spec and to progenitor

::: notes
- openapi spec has been available since kc 22 and used as intermediate artifact for generating the html docs
- current nightly also publishes openapi spec files directly with a warning they might be incomplete
  - https://github.com/keycloak/keycloak/pull/22940
  - probably part of kc 24
- compilation errors include authTime vs auth_time, missing operation ids, multiple 2xx responses, array query parameters, multipile body-media types etc
- sadly kc build process for frontend (mvn just downloads and runs a node binary‽) doesn't really work in nix
:::

# Rust Tooling

- Nix to generate OpenAPI spec for a specific Keycloak version with specific patches applied
- progenitor to generate low-level Rust API client from spec
- high(er) level abstractions to handle access/refresh tokens, pagination, etc.
- cli tool to actually do something useful

::: notes
- library (i.e. low-level + high-level API client) to be published, probably somewhere in github.com/relaxdays
:::

# {.plain .noframenumbering}

\centering
\vfill
\fontsize{40}{50}\selectfont Demo
\vfill

# Future steps

- more complete OpenAPI documentation in Keycloak
- disentangle Keycloak API client library from tool
- more high-level abstractions
- publish library as Rust crate

# Links + Contact

- publishing OpenAPI spec: https://github.com/keycloak/keycloak/pull/22940
- OpenAPI tracking issue: https://github.com/keycloak/keycloak/issues/25563

\ 

- Email/Matrix/Fediverse: `<separator> sophie <separator> catgirl.cloud`

# {.plain .noframenumbering}

\centering
\vfill
\fontsize{40}{50}\selectfont Q/A
\vfill
