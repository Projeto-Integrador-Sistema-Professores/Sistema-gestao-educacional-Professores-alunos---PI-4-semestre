package com.sistema.service;

import com.mongodb.client.gridfs.GridFSBucket;
import com.mongodb.client.gridfs.GridFSBuckets;
import com.mongodb.client.gridfs.GridFSDownloadStream;
import com.mongodb.client.gridfs.model.GridFSFile;
import com.mongodb.client.gridfs.model.GridFSUploadOptions;
import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

@Service
public class GridFSService {
    
    @Autowired
    private MongoTemplate mongoTemplate;
    
    private GridFSBucket getGridFSBucket() {
        return GridFSBuckets.create(mongoTemplate.getDb(), "files");
    }
    
    public String uploadFile(MultipartFile file) throws IOException {
        GridFSBucket gridFSBucket = getGridFSBucket();
        GridFSUploadOptions options = new GridFSUploadOptions()
                .metadata(new org.bson.Document("contentType", file.getContentType())
                        .append("originalName", file.getOriginalFilename()));
        
        ObjectId fileId = gridFSBucket.uploadFromStream(
                file.getOriginalFilename(),
                file.getInputStream(),
                options
        );
        
        return fileId.toString();
    }
    
    public byte[] downloadFile(String fileId) throws IOException {
        GridFSBucket gridFSBucket = getGridFSBucket();
        GridFSDownloadStream downloadStream = gridFSBucket.openDownloadStream(new ObjectId(fileId));
        
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        byte[] buffer = new byte[4096];
        int bytesRead;
        
        while ((bytesRead = downloadStream.read(buffer)) != -1) {
            outputStream.write(buffer, 0, bytesRead);
        }
        
        downloadStream.close();
        return outputStream.toByteArray();
    }
    
    public void deleteFile(String fileId) {
        GridFSBucket gridFSBucket = getGridFSBucket();
        gridFSBucket.delete(new ObjectId(fileId));
    }
    
    public GridFSFile getFileMetadata(String fileId) {
        GridFSBucket gridFSBucket = getGridFSBucket();
        org.bson.Document query = new org.bson.Document("_id", new ObjectId(fileId));
        return gridFSBucket.find(query).first();
    }
    
    public org.bson.Document getFileMetadataAsDocument(String fileId) {
        GridFSFile file = getFileMetadata(fileId);
        if (file == null) {
            return null;
        }
        org.bson.Document doc = new org.bson.Document();
        doc.put("_id", file.getId());
        doc.put("filename", file.getFilename());
        doc.put("length", file.getLength());
        doc.put("uploadDate", file.getUploadDate());
        doc.put("metadata", file.getMetadata());
        return doc;
    }
}

