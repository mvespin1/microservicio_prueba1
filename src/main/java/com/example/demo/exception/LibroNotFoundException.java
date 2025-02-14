package com.example.demo.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class LibroNotFoundException extends RuntimeException {
    
    public LibroNotFoundException(String mensaje) {
        super(mensaje);
    }
    
    public LibroNotFoundException(Long id) {
        super("No se encontró el libro con ID: " + id);
    }
} 