FROM ntopus/dev-image-firefox-node:lts
RUN wget -O vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868
RUN dpkg -i vscode.deb; \
  apt-get update; \
  apt-get -fy install
RUN apt-get install -y git
RUN rm -f ./vscode.deb
RUN apt-get clean
USER node
RUN code --install-extension GulajavaMinistudio.javascript-complete-packs
RUN code --uninstall-extension eg2.tslint
RUN code --uninstall-extension WakaTime.vscode-wakatime
USER root
ENV DISPLAY :0