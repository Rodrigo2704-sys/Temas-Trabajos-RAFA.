const PrimerNombre="Rodrigo";
const PrimerApellido="Grajales";
const vectorSemana=["Lunes","Martes","Miercoles","Jueves"];
const direccion={
    ciudad:"Pereira",
    departamento:"Risaralda", 
    barrio:"Tokio"
}

export function SegundoComponente(){

    return (

        <>
          <h1>{PrimerNombre}</h1>
          <h1>{PrimerApellido}</h1>
          <p>{vectorSemana.join(' , ')}</p>
          <p>(2+2)</p>

          <p style={{
            backgroundColor:"red",
            borderRadius:10,
            padding:10
          }}>{JSON.stringify(direccion)}</p>
          
        </>

    

    );
}
