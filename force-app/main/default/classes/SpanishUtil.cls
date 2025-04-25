public class SpanishUtil {
    public static String spanishAttachVal(String val){
        if(val == 'W9'){
            return 'W9';
        }
        if(val == 'Direct Deposit Agreement'){
            return 'Acuerdo de Depósito Directo';
        }
        if(val == 'Voided Check'){
            return 'Cheque anulado';
        }
        if(val == 'TIN Documentation (Social Security Card or IRS Notice of Assignment of TIN)'){
            return 'Documentación de TIN (Tarjeta de Seguro Social o Notificación de Asignación de TIN del IRS)';
        }
        if(val == 'Driver’s License/Photo Id'){
            return 'Licencia de conducir / Identificación con foto';
        }
        if(val == 'Insurance Agreement REI'){
            return 'Acuerdo de seguro REI';
        }
        if(val == 'Insurance Agreement Premier'){
            return 'Acuerdo de seguro Premier';
        }
        if(val == 'Insurance Agreement PPMG TX'){
            return 'Acuerdo de seguro PPMG TX';
        }
        if(val == 'Certificate of Insurance - General Liability'){
            return 'Certificado de seguro - Responsabilidad general';
        }
        if(val == 'Certificate of Insurance or Waiver - Workers Comp'){
            return 'Certificado de Seguro o Renuncia - Compensación de Trabajadores';
        }
        if(val == 'Permanent Resident Card / Green Card'){
            return 'Tarjeta de Residencia Permanente / Tarjeta Verde';
        }
        if(val == 'Employment Authorization Document / Work Permit'){
            return 'Documento de Autorización de Empleo / Permiso de Trabajo';
        }
        if(val == 'Employment Visa'){
            return 'Visa de empleo';
        }
        if(val == 'Hold Harmless Agreement REI'){
            return 'Mantenga el Acuerdo Inofensivo REI';
        }
        if(val == 'Hold Harmless Agreement PPMG TX'){
            return 'Mantenga un acuerdo inofensivo PPMG TX';
        }
        if(val == 'Hold Harmless Agreement Premier'){
            return 'Mantenga el acuerdo inofensivo Premier';
        }
        if(val == 'License'){
            return 'Licencia';
        }
        if(val == 'Permits'){
            return 'Permisos';
        }
        return val;
    }
    
    public static String spanishAttachType(String val){
        if(val == 'Approved / Filed'){
            return 'Aprobado / Archivado';
        }
        if(val == 'Uploaded'){
            return 'Cargada';
        }
        if(val == 'Rejected'){
            return 'Rechazado';
        }
        if(val == 'Expired'){
            return 'Muerta';
        }
        if(val == 'New Upload Required'){
            return 'Nueva carga requerida';
        }
        return val;
    }
    
    public static String spanishRehabTradeVal(String val){
        if(val == 'Cages'){
            return 'Jaulas';
        }
        if(val == 'Carpet'){
            return 'Alfombra';
        }
        if(val == 'Cleaning'){
            return 'Limpieza';
        }
        if(val == 'Concrete'){
            return 'Hormigón';
        }
        if(val == 'Electrical'){
            return 'Eléctrica';
        }
        if(val == 'Engineer'){
            return 'Ingeniero';
        }
        if(val == 'Foundation'){
            return 'Fundación';
        }
        if(val == 'Garage Doors'){
            return 'Puertas de garaje';
        }
        if(val == 'Gas'){
            return 'Gas';
        }
        if(val == 'Handyman'){
            return 'Personal de mantenimiento';
        }
        if(val == 'Hardwoods'){
            return 'Maderas duras';
        }
        if(val == 'HVAC'){
            return 'HVAC';
        }
        if(val == 'Inspector'){
            return 'Inspectora';
        }
        if(val == 'Locks'){
            return 'Cabellos';
        }
        if(val == 'Move Outs'){
            return 'Mover salidas';
        }
        if(val == 'Painter'){
            return 'Pintora';
        }
        if(val == 'Pest Control'){
            return 'Control de plagas';
        }
        if(val == 'Plumbing'){
            return 'Plomería';
        }
        if(val == 'Project Manager'){
            return 'Gerente de proyecto';
        }
        if(val == 'Rehab'){
            return 'Rehabilitación';
        }
        if(val == 'Roofs'){
            return 'Techos';
        }
        if(val == 'Trash'){
            return 'Basura';
        }
        if(val == 'Utility/City'){
            return 'Utilidad / Ciudad';
        }
        if(val == 'Yard Crew'){
            return 'Tripulación de la yarda';
        }
        if(val == 'Inspector'){
            return 'Inspectora';
        }
        return val;
    }
    /*Public String spanishMaintenanceTradeVal(String val){
        if(val == 'Cages'){
            return 'Jaulas';
        }
        if(val == 'Carpet'){
            return 'Alfombra';
        }
        if(val == 'Cleaning'){
            return 'Limpieza';
        }
        if(val == 'Concrete'){
            return 'Hormigón';
        }
        if(val == 'Electrical'){
            return 'Eléctrica';
        }
        if(val == 'Engineer'){
            return 'Ingeniero';
        }
        if(val == 'Foundation'){
            return 'Fundación';
        }
        if(val == 'Garage Doors'){
            return 'Puertas de garaje';
        }
        if(val == 'Handyman'){
            return 'Personal de mantenimiento';
        }
        if(val == 'Hardwoods'){
            return 'Maderas duras';
        }
        if(val == 'HVAC'){
            return 'HVAC';
        }
        if(val == 'Locks'){
            return 'Cabellos';
        }
        if(val == 'Move Outs'){
            return 'Mover salidas';
        }
        if(val == 'Pest Control'){
            return 'Control de plagas';
        }
        if(val == 'Plumbing'){
            return 'Plomería';
        }
        if(val == 'Rehab'){
            return 'Rehabilitación';
        }
        if(val == 'Roofs'){
            return 'Techos';
        }
        if(val == 'Trash'){
            return 'Basura';
        }
        if(val == 'Yard Crew'){
            return 'Tripulación de la yarda';
        }
        if(val == 'Inspector'){
            return 'Inspectora';
        }
        return val;
    }*/
    
    public static String primaryConInfo(String val){
        return 'El contacto principal tendrá la autoridad para cambiar, modificar o crear nuevos contactos, información bancaria, dirección comercial y números de teléfono, junto con todos los documentos archivados en este registro maestro de proveedores. Considere cuidadosamente la asignación de contacto principal.';
    }
}