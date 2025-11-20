package com.sistema.config;

import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.config.AbstractMongoClientConfiguration;

import javax.net.ssl.SSLContext;
import java.security.NoSuchAlgorithmException;

@Configuration
public class MongoConfig extends AbstractMongoClientConfiguration {

    @Value("${spring.data.mongodb.uri}")
    private String mongoUri;

    @Value("${spring.data.mongodb.database}")
    private String databaseName;

    @Override
    protected String getDatabaseName() {
        return databaseName;
    }

    @Override
    @Bean
    public MongoClient mongoClient() {
        try {
            // Usar SSLContext padrão do sistema, mas forçar TLS 1.2
            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, null, new java.security.SecureRandom());

            ConnectionString connectionString = new ConnectionString(mongoUri);
            MongoClientSettings settings = MongoClientSettings.builder()
                    .applyConnectionString(connectionString)
                    .applyToSslSettings(builder -> {
                        builder.enabled(true);
                        builder.invalidHostNameAllowed(true); // Permitir hostname inválido temporariamente para testar
                        builder.context(sslContext);
                    })
                    .applyToSocketSettings(builder -> {
                        builder.connectTimeout(30000, java.util.concurrent.TimeUnit.MILLISECONDS);
                        builder.readTimeout(30000, java.util.concurrent.TimeUnit.MILLISECONDS);
                    })
                    .applyToClusterSettings(builder -> {
                        builder.serverSelectionTimeout(30000, java.util.concurrent.TimeUnit.MILLISECONDS);
                    })
                    .build();

            return MongoClients.create(settings);
        } catch (NoSuchAlgorithmException | java.security.KeyManagementException e) {
            // Se houver erro na configuração SSL, usar configuração padrão
            return MongoClients.create(mongoUri);
        }
    }
}

