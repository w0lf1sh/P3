/// @file

#include <iostream>
#include <fstream>
#include <string.h>
#include <errno.h>

#include "wavfile_mono.h"
#include "pitch_analyzer.h"

#include "docopt.h"

#define FRAME_LEN 0.030   /* 30 ms. */
#define FRAME_SHIFT 0.015 /* 15 ms. */

using namespace std;
using namespace upc;

static const char USAGE[] = R"(
get_pitch - Pitch Detector 

Usage:
    get_pitch [options] <input-wav> <output-txt> 
    get_pitch (-h | --help)
    get_pitch --version

Options:
    -p FLOAT, --p_th=FLOAT         Margen en dBs para la potencia [default: -20.0]
    -r FLOAT, --r1_th=FLOAT        Margen de la autocorrelación normalizada en 1 [default: 0.9]
    -m FLOAT, --rlag_th=FLOAT      Margen de la autocorrelación normalizada en posición de pitch [default: 0.4]
    -x FLOAT, --x_th=FLOAT         Margen de center-clipping [default: 0.00007]
    -h, --help                     Show this screen
    --version                      Show the version of the project

Arguments:
    input-wav   Wave file with the audio signal
    output-txt  Output file: ASCII file with the result of the detection:
                    - One line per frame with the estimated f0
                    - If considered unvoiced, f0 must be set to f0 = 0
)";

//    -x FLOAT, --x_th=FLOAT         Offset de la técnica de preprocesado Center-Clipping [default: ]
int main(int argc, const char *argv[]) {
	/// \TODO 
	///  Modify the program syntax and the call to **docopt()** in order to
	///  add options and arguments to the program.
    std::map<std::string, docopt::value> args = docopt::docopt(USAGE,
        {argv + 1, argv + argc},	// array of arguments, without the program name
        true,    // show help if requested
        "2.0");  // version string

  std::string input_wav = args["<input-wav>"].asString();
  std::string output_txt = args["<output-txt>"].asString();

  float p = std::stof(args["--p_th"].asString());
  float r1 = std::stof(args["--r1_th"].asString());
  float rlag = std::stof(args["--rlag_th"].asString());
  float x_th = std::stof(args["--x_th"].asString());
  /// \DONE Paso de parámetros por consola implementado
  // Read input sound file
  unsigned int rate;
  vector<float> x;
  if (readwav_mono(input_wav, rate, x) != 0)
  {
    cerr << "Error reading input file " << input_wav << " (" << strerror(errno) << ")\n";
    return -2;
  }

  int n_len = rate * FRAME_LEN;
  int n_shift = rate * FRAME_SHIFT;

  // Define analyzer
  PitchAnalyzer analyzer(n_len, rate, p, r1, rlag, PitchAnalyzer::HAMMING, 50, 500);

  /// \TODO
  /// Preprocess the input signal in order to ease pitch estimation. For instance,
  /// central-clipping or low pass filtering may be used.
  #if 0
  float x_th = 0.00005;
  for (unsigned int n=0; n < x.size(); n++){
    if(x[n]>x_th){
      x[n] = x[n] - x_th;
    }else if(x[n]< -x_th){
      x[n] = x[n] + x_th;
    }else
    x[n] = 0;
  }
  ///DONE Center clipping implementado (con offset)
  #endif

   #if 1
  for (unsigned int n=0; n < x.size(); n++){
    if(x[n]<x_th && x[n]>-x_th){
      x[n] = 0;
    }
  }
  ///DONE Center clipping implementado (sin offset)
  #endif
  
  // Iterate for each frame and save values in f0 vector
  vector<float>::iterator iX;
  vector<float> f0;
  for (iX = x.begin(); iX + n_len < x.end(); iX = iX + n_shift)
  {
    float f = analyzer(iX, iX + n_len); //El operador '()' nos calcula el pitch del frame x (mirar pitch_analyzer.h)
    f0.push_back(f);
  }

  /// \TODO
  /// Postprocess the estimation in order to supress errors. For instance, a median filter
  /// or time-warping may be used.
#if 1
  for (unsigned int i = 1; i < f0.size() - 1; i++)
  {
    vector<float> arr;
    arr.push_back(f0[i]);
    arr.push_back(f0[i + 1]);
    arr.push_back(f0[i - 1]);

    //sorting array
    if (arr[1] < arr[0])
      swap(arr[0], arr[1]);

    if (arr[2] < arr[1])
    {
      swap(arr[1], arr[2]);
      if (arr[1] < arr[0])
        swap(arr[1], arr[0]);
    }
    f0[i] = arr[1];
  }
  /// \DONE Implementado filtro de 3 posiciones de mediana.
#endif
// Write f0 contour into the output file
ofstream os(output_txt);
if (!os.good())
{
  cerr << "Error reading output file " << output_txt << " (" << strerror(errno) << ")\n";
  return -3;
}

os << 0 << '\n'; //pitch at t=0
for (iX = f0.begin(); iX != f0.end(); ++iX)
  os << *iX << '\n';
os << 0 << '\n'; //pitch at t=Dur

return 0;
}
