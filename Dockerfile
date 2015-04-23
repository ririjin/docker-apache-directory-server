ROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list

RUN sed -i "s/http:\/\/archive\.ubuntu\.com/http:\/\/mirrors\.aliyun\.com/g" /etc/apt/sources.list

# Install oracle-jdk8
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list \
    && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
    && apt-get update && apt-get upgrade -y \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && apt-get install -y oracle-java8-installer \
    && apt-get install oracle-java8-set-default \
    && apt-get install unzip zip


# Set environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JRE_HOME /usr/lib/jvm/java-8-oracle/jre

RUN cd /usr/local && \
    wget http://archive.apache.org/dist/directory/apacheds/dist/2.0.0-M17/apacheds-2.0.0-M17.zip && \
    unzip apacheds-2.0.0-M17.zip && \
    chmod a+x apacheds-2.0.0-M17/bin/apacheds.sh && \
    rm apacheds-2.0.0-M17.zip && \
    cd /bin && rm sh && ln -s bash sh

# Clean up
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

RUN mkdir -p /usr/local/apacheds-2.0.0-M17/instances/default/conf

EXPOSE 10389

CMD java -Dapacheds.controls=org.apache.directory.api.ldap.codec.controls.cascade.CascadeFactory,org.apache.directory.api.ldap.codec.controls.manageDsaIT.ManageDsaITFactory,org.apache.directory.api.ldap.codec.controls.search.entryChange.EntryChangeFactory,org.apache.directory.api.ldap.codec.controls.search.pagedSearch.PagedResultsFactory,org.apache.directory.api.ldap.codec.controls.search.persistentSearch.PersistentSearchFactory,org.apache.directory.api.ldap.codec.controls.search.subentries.SubentriesFactory,org.apache.directory.api.ldap.extras.controls.ppolicy_impl.PasswordPolicyFactory,org.apache.directory.api.ldap.extras.controls.syncrepl_impl.SyncDoneValueFactory,org.apache.directory.api.ldap.extras.controls.syncrepl_impl.SyncInfoValueFactory,org.apache.directory.api.ldap.extras.controls.syncrepl_impl.SyncRequestValueFactory,org.apache.directory.api.ldap.extras.controls.syncrepl_impl.SyncStateValueFactory -Dapacheds.extendedOperations=org.apache.directory.api.ldap.extras.extended.ads_impl.cancel.CancelFactory,org.apache.directory.api.ldap.extras.extended.ads_impl.certGeneration.CertGenerationFactory,org.apache.directory.api.ldap.extras.extended.ads_impl.gracefulShutdown.GracefulShutdownFactory,org.apache.directory.api.ldap.extras.extended.ads_impl.storedProcedure.StoredProcedureFactory,org.apache.directory.api.ldap.extras.extended.ads_impl.gracefulDisconnect.GracefulDisconnectFactory -Dlog4j.configuration=file:/usr/local/apacheds-2.0.0-M17/instances/default/conf/log4j.properties -Dapacheds.log.dir=/usr/local/apacheds-2.0.0-M17/instances/default/log -classpath /usr/local/apacheds-2.0.0-M17/lib/apacheds-service-2.0.0-M17.jar org.apache.directory.server.UberjarMain /usr/local/apacheds-2.0.0-M17/instances/default
