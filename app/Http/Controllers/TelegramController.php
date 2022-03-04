<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Log;
use TelegramBot\Api\BotApi;
use TelegramBot\Api\Exception;
use TelegramBot\Api\InvalidArgumentException;

class TelegramController extends Controller
{
    private BotApi $telegram;

    /**
     * TelegramController constructor.
     */
    public function __construct(){
        $this->telegram = new BotApi(Config::get('telegram.api_key'));
    }

    /**
     * Send message to Telegram
     * @param $settings
     */
    public function sendMessage($settings){
        try {
            $this->telegram->sendMessage($settings['to'], $settings['message']);
        } catch (InvalidArgumentException|Exception $e) {
            Log::error('TelegramController -> sendMessage() ' . $e->getMessage());
        }
    }

    /*
     * Receive message from Telegram
     */
    public function receiveMessage(Request $request){
        $msgChatId = $request->json('message.from.id');
        $msgText   = $request->json('message.text');
        $userName  = $request->json('message.from.first_name');
        $settings  = [
            'to' => $msgChatId,
            'message' => ''
        ];
        switch ($msgText) {
            case '/start':
                $settings['message'] = "Hi $userName!
                \nI'm a Automessage bot. Nice to meet you!
                \nThis $msgChatId is our chat id. You will need it when you send events from your system to Automessage.";
                break;
            default:
                $settings['message'] = "I'm a bot but I haven't been fully configured yet.\nSorry!";
                break;
        }
        $this->sendMessage($settings);
    }
}
