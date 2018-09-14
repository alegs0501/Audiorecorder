//
//  RecordProController.swift
//  RecordPro
//
//  Created by Pablo Mateo Fernández on 02/02/2017.
//  Copyright © 2017 355 Berry Street S.L. All rights reserved.
//
/*
 AVFoundation
    AVAudioPlayer -> reproducir
    AVAudioRecorder -> grabar
    DELEGATE: AVAudioRecorderDelegate
 *Para grabar se necesita
    -La URL de un archivo de sonido que crear
    -Crear una sesion de audio(AudioSession)
 */
import UIKit
import AVFoundation

class RecordProController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet private var stopButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var recordButton: UIButton!
    @IBOutlet private var timeLabel: UILabel!
    
    //Crear una instancia del recorder y el palyer
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var elapsedTimeInSeconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configuracion botones
        stopButton.isEnabled = false
        playButton.isEnabled = false
        
        
        // Obtenemos el path de Documents
        guard let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            let alerta = UIAlertController(title: "Error", message: "No se encuentra la carpeta Documentos", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            return
        }
        let audioFileUrl = directoryUrl.appendingPathComponent("MiAudio.m4a")
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            
            let recorderSettings: [String:Any] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44100.0, AVNumberOfChannelsKey: 2, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            audioRecorder = try AVAudioRecorder(url: audioFileUrl, settings: recorderSettings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        }catch{
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Action methods
    
    @IBAction func stop(sender: UIButton) {
        recordButton.setImage(UIImage(named: "Record") , for: .normal)
        recordButton.isEnabled = true
        stopButton.isEnabled = false
        playButton.isEnabled = true
        
        audioRecorder?.stop()
        audioPlayer?.stop()
        resetTimer()
        
        let audioSession = AVAudioSession.sharedInstance()
        do{
            try audioSession.setActive(false)
        } catch {
            print(error)}
    }

    @IBAction func play(sender: UIButton) {
        recordButton.isEnabled = false
        stopButton.isEnabled = true
        
        if let recorder = audioRecorder{
            if !recorder.isRecording{
                audioPlayer = try? AVAudioPlayer(contentsOf: recorder.url)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                fireTimer()
            }
        }
    }

    @IBAction func record(sender: UIButton) {
        //detener el reproductor
        if let player = audioPlayer {
            if player.isPlaying {
                player.stop()
            }
        }
        
        //Grabar
        if let recorder = audioRecorder {
            //Comprobar si esta grabando
            if !recorder.isRecording {
                //Entonces grabar
                let audioSession = AVAudioSession.sharedInstance()
                do{
                    try audioSession.setActive(true)
                    recorder.record()
                    fireTimer()
                    //Grabando cambiar boton de grabar a pause
                    recordButton.setImage(UIImage(named: "Pause") , for: .normal)
                }catch{
                    print(error)
                }
            } else {
                //si esta grabando pausa la app
                recorder.pause()
                pauseTimer()
                //cambiar la imagen del boton
                recordButton.setImage(UIImage(named: "Record") , for: .normal)
            }
        }
        
        stopButton.isEnabled = true
        playButton.isEnabled = false
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alerta = UIAlertController(title: "Grabacion Terminada", message: "Audio grabado en sistema", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            let alerta = UIAlertController(title: "Reproduciion Terminada", message: "Enjoy it", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            recordButton.isEnabled = true
            stopButton.isEnabled = false
        }
    }
    
    func fireTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.elapsedTimeInSeconds += 1
            self.updateContadorLabel()
        })
    }
    
    func updateContadorLabel() {
        let segundos = elapsedTimeInSeconds % 60
        let minutos = (elapsedTimeInSeconds / 60) % 60
        timeLabel.text = String(format: "%02d:%02d", minutos, segundos)
    }
    
    func pauseTimer(){
        timer?.invalidate()
    }
    
    func resetTimer(){
        timer?.invalidate()
        elapsedTimeInSeconds = 0
        updateContadorLabel()
    }

}
