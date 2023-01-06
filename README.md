# nix-at-fabriq

This repository holds the Nix-darwin configuration common to engineers at Fabriq.

## State of the project

Usage of Nix and Nix-darwin at Fabriq is still at a Proof-of-Concept stage. We are relying on it to reproduce the upstream team's development environment, but not much else. Our goal for now is to ensure that people can install the software without any hurdles.

## Purpose

A usual pain in tech companies is setting up the devices of new hires with a development environment. Most often, engineers cobble up a setup script to automate this process, but it faces two issues:

- The setup script often has flaws when run on a brand new machine, because of software updates and the inability of already-hired engineers to test the script from a clean state.
- The setup script will evolve according to desired changes of the development environments, but engineers that already ran the script on their devices will not benefit from the evolutions. Thus, development environments between engineers will drift, making some issues difficult to reproduce.

With Nix and Nix-darwin, we can declaratively define the state of the engineers' devices, thus ensuring that everyone has the same working development environment — now, and over time.

## Disclaimer

Nix and Nix-darwin are wonderful technologies, in that they enable a maximum level of automation and reproducibility, at least compared to all other technologies used for the same purpose. It is also very lightweight, as there are no runtime costs to speak of — compared to something like Docker, which doesn't solve the problem as well while causing performance issues.

**However**, Nix and Nix-darwin are not user-friendly. Although Nix is a 20-year-old project and its main repository is among GitHub's most active ones, it is not mature enough for mainstream use. By relying on Nix at Fabriq, we exchange a set of issues for another set of issues: bugs, lack of documentation, frictions, etc.

This tradeoff has been made knowingly. For every minute wasted by some issue with Nix, know that you might have saved more than if we were still using a botched setup script.
